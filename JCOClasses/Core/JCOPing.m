//
//  JCOPing.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//

#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "JCOPing.h"
#import "JCO.h"
#import "JCOIssueStore.h"

@implementation JCOPing

- (void)start {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPingDelayed) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)sendPingDelayed {
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendPing) userInfo:nil repeats:NO];
}

- (void)sendPing {

    NSString *project = [[JCO instance] getProjectName];
    NSString *uuid = [[JCO instance] getUUID];
    
    NSString *resourceUrl =
            [NSString stringWithFormat:@"rest/jconnect/latest/issue/withcomments?project=%@&uuid=%@", project, uuid];

    NSURL *url = [NSURL URLWithString:resourceUrl relativeToURL:self.baseUrl];
    NSLog(@"Pinging...%@", url);

// send ping

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
/*
     {"ping-response":
     {"issue-updates":
     [{"issue-update":
     {"issueKey":"JRA-1330","message":"JRA-1330 has been closed: Won't fix"}}
     ]}}
     */

    NSString *responseString = [request responseString];

//    NSLog(@"ping response: '%@'", responseString);

    if ([responseString isEqualToString:@"null"] || [responseString isEqualToString:@""]) {
        return;
    }

/*
'{"updatedIssuesWithComments":[],"oldIssuesWithComments":[{"key":"JCONNECT-2","status":"Open","comments":[]},{"key":"JCONNECT-1","status":"Open","title":"test","description":"Hello","comments":[{"systemuser":true,"username":"admin","text":"Hello dude"}]}]}'
*/

    NSDictionary *data = [responseString JSONValue];
    [[JCOIssueStore instance] updateWithData:data];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JCODidReceiveIssueCommentsNotification" object:self]; // TODO use a constant for this.
}

@synthesize baseUrl = _baseUrl;

- (void)dealloc {
    self.baseUrl = nil;
    [super dealloc];
}


@end

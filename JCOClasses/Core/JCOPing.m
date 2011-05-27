
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

    NSString *project = [[JCO instance] getProject];
    NSString *uuid = [[JCO instance] getUUID];
    NSNumber* lastPingTime = [[NSUserDefaults standardUserDefaults] objectForKey:kJCOLastSuccessfulPingTime];
    NSString *resourceUrl = [NSString stringWithFormat:kJCOTransportNotificationsPath, project, uuid, lastPingTime];

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

    if ([responseString isEqualToString:@"null"] || [responseString isEqualToString:@""]) {
        return;
    }

    /*
    { "sinceMillis" : 23456
      "updatedIssuesWithComments":[],
      "oldIssuesWithComments":[
         {"key":"JCONNECT-2","status":"Open","comments":[]},
         {"key":"JCONNECT-1","status":"Open","title":"test","description":"Hello",
                "comments":[{"systemuser":true,"username":"admin","text":"Hello dude"}]}]
     }
    */
    if (request.responseStatusCode < 300)
    {
        NSDictionary *data = [responseString JSONValue];
        [[JCOIssueStore instance] updateWithData:data];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJCOReceivedCommentsNotification object:self]; // TODO use a constant for this.
        // update the timestamp since we last requested comments.
        // sinceMillis is the server's time
        NSNumber *sinceMillis = [data valueForKey:@"sinceMillis"];
        [[NSUserDefaults standardUserDefaults] setObject:sinceMillis forKey:kJCOLastSuccessfulPingTime];
    }
    else
    {
        NSLog(@"Error request comments and issues: %@", responseString);
    }
}

@synthesize baseUrl = _baseUrl;

- (void)dealloc {
    self.baseUrl = nil;
    [super dealloc];
}


@end

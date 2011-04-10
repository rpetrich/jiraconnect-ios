//
//  JCPing.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "JCPing.h"
#import "JCO.h"
#import "JCIssueStore.h"

@implementation JCPing


- (void) sendPing:(NSURL*)baseUrl {

    NSLog(@"baseUrl = %@", [baseUrl absoluteString]);
    
    NSString* resourceUrl = [NSString stringWithFormat:@"rest/jconnect/latest/issue/withcomments?project=JCONNECT&udid=%@", [[[JCO instance] getMetaData] objectForKey:@"udid"]];
    
    NSLog(@"resourceUrl = %@", resourceUrl);
    
	NSURL* url = [NSURL URLWithString:resourceUrl relativeToURL:baseUrl];
	NSLog(@"Pinging...%@", url);
		
	// send ping
    
	ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	/*
	 {"ping-response":
	 {"issue-updates":
	 [{"issue-update":
	 {"issueKey":"JRA-1330","message":"JRA-1330 has been closed: Won't fix"}}
	 ]}}
	 */
	    
    NSString* responseString = [request responseString];
	
	NSLog(@"ping response: '%@'", responseString);
	
	if ([responseString isEqualToString:@"null"] || [responseString isEqualToString:@""]) {
		return;
	}
	
    /*
     '{"updatedIssuesWithComments":[],"oldIssuesWithComments":[{"key":"JCONNECT-2","status":"Open","comments":[]},{"key":"JCONNECT-1","status":"Open","title":"test","description":"Hello","comments":[{"username":"admin","text":"Hello dude"}]}]}'
     */
    
 	NSDictionary* data = [responseString JSONValue];
    [[JCIssueStore instance] updateWithData:data];
}

@end

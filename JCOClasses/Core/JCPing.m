//
//  JCPing.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCPing.h"
#import "JCLocation.h"
#import "JCO.h"
#import "JCIssueStore.h"

@implementation JCPing

- (void) dealloc {
	[_location release]; _location = nil;
	[_notifications release]; _notifications = nil;
	[super dealloc];
}

- (id)initWithLocator:(JCLocation*) locator notifications:(JCNotifications*)notes {
	if ((self = [super init])) {
		_location = [locator retain];
		_notifications = [notes retain];
	}
	return self;
}

- (void) sendPing:(NSURL*)baseUrl {
	
    /*
	NSURL* baseUrl = [timer userInfo];
	NSURL* url = [NSURL URLWithString:@"rest/jconnect/latest/ping" relativeToURL:baseUrl];
	NSLog(@"Pinging...%@", url);
	

	// get app data
	
	NSMutableDictionary* pingObj = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
	[pingObj setObject:[[JCO instance] getMetaData] forKey:@"ping"];
	
	NSLog(@"Ping data : %@", [pingObj JSONRepresentation]);
	
	// send ping

	ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
	[request setRequestMethod:@"POST"];
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request appendPostData: [[pingObj JSONRepresentation] dataUsingEncoding: NSUTF8StringEncoding]];
	[request setDelegate:self];
	[request startAsynchronous];	
     */
    NSLog(@"baseUrl = %@", [baseUrl absoluteString]);
    
    NSString* resourceUrl = [NSString stringWithFormat:@"rest/jconnect/latest/issue/withcomments?project=JCONNECT&udid=%@", [[[JCO instance] getMetaData] objectForKey:@"udid"]];
    
    NSLog(@"resourceUrl = %@", resourceUrl);
    
	NSURL* url = [NSURL URLWithString:resourceUrl relativeToURL:baseUrl];
	NSLog(@"Pinging...%@", url);
	
    
	// get app data
	
	// send ping
    
	ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
	//[request setRequestMethod:@"GET"];
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
	
    /*
	NSString* responseString = [request responseString];
	
	NSLog(@"ping response: %@", responseString);
	
	if ([responseString isEqualToString:@"null"]) {
		return;
	}
	
	NSDictionary* data = [responseString JSONValue];
	NSArray* issueUpdates = [data objectForKey:@"issue-updates"];
	for (NSDictionary* issueUpdate in issueUpdates)
	{
		NSString* message = [issueUpdate objectForKey:@"message"];
		NSLog(@"adding note: %@", message);
		[_notifications add:message];
	}
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

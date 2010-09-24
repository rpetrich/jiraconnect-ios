//
//  JCPing.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCPing.h"
#import "JCLocation.h"
#import "JCSetup.h"

@implementation JCPing

- (void) dealloc {
	[_location release]; _location = nil;
	[_notifications release]; _notifications = nil;
	[super dealloc];
}

- (id)initWithLocator:(JCLocation*) locator notifications:(JCNotifications*)notes {
	if (self = [super init]) {
		_location = [locator retain];
		_notifications = [notes retain];
	}
	return self;
}

- (void) startPinging:(NSURL*) url {
//	[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendPing:) userInfo:url repeats:YES];
	NSLog(@"Start pinging...");
}

- (void) sendPing:(NSTimer*) timer {
	
	NSURL* baseUrl = [timer userInfo];
	NSURL* url = [NSURL URLWithString:@"rest/jconnect/latest/ping" relativeToURL:baseUrl];
	NSLog(@"Pinging...%@", url);
	

	// get app data
	
	NSMutableDictionary* pingObj = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
	[pingObj setObject:[[JCSetup instance] getMetaData] forKey:@"ping"];
	
	NSLog(@"Ping data : %@", [pingObj JSONRepresentation]);
	
	// send ping

	ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
	[request setRequestMethod:@"POST"];
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request appendPostData: [[pingObj JSONRepresentation] dataUsingEncoding: NSUTF8StringEncoding]];
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
	
	NSLog(@"ping response: %@", responseString);
	
	NSDictionary* data = [responseString JSONValue];
	NSDictionary* pingResponse = [data objectForKey:@"ping-response"];
	NSArray* issueUpdates = [pingResponse objectForKey:@"issue-update"];
	for (NSDictionary* issueUpdate in issueUpdates)
	{
		NSString* message = [issueUpdate objectForKey:@"message"];
		[_notifications add:message];
	}
	
}

@end

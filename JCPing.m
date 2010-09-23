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
	[super dealloc];
}

- (id) initWithLocator:(JCLocation*)locator {
	if (self = [super init]) {

		_location = locator;
	}
	return self;
}

- (void) startPinging:(NSURL*) url {
	[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendPing:) userInfo:url repeats:YES];
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
	[request startAsynchronous];
	
}

@end

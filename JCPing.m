//
//  JCPing.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCPing.h"
#import "JCLocation.h"

@implementation JCPing

- (void) dealloc {
	[_location release]; _location = nil;
	[super dealloc];
}

- (id) init {
	if (self = [super init]) {
		_location = [[JCLocation alloc] init];
	}
	return self;
}

- (void) startPinging:(NSURL*) url {
	// TODO start a pinger NSTimer..
	[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendPing:) userInfo:url repeats:YES];
	NSLog(@"Start pinging...");
}

- (void) sendPing:(NSTimer*) timer {
	
	NSURL* baseUrl = [timer userInfo];
	NSURL* url = [NSURL URLWithString:@"rest/jconnect/latest/ping" relativeToURL:baseUrl];
	NSLog(@"Pinging...%@", url);
	UIDevice* device = [UIDevice currentDevice];
	NSDictionary* appMetaData = [[NSBundle mainBundle] infoDictionary];
	
	
	NSMutableDictionary* info = [[[NSMutableDictionary alloc] initWithCapacity:20] autorelease];
	
	// add device data
	[info setObject:[device uniqueIdentifier] forKey:@"udid"];
	[info setObject:[device name] forKey:@"devName"];
	[info setObject:[device systemName] forKey:@"systemName"];
	[info setObject:[device systemVersion] forKey:@"systemVersion"];
	[info setObject:[device model] forKey:@"model"];
	
	// app application data (we could make these two separate dicts but cbf atm)
	[info setObject:[appMetaData objectForKey:@"CFBundleVersion"] forKey:@"appVersion"];
	[info setObject:[appMetaData objectForKey:@"CFBundleName"] forKey:@"appName"];
	[info setObject:[appMetaData objectForKey:@"CFBundleIdentifier"] forKey:@"appId"];
	
	// location data
	[info setObject:[NSString stringWithFormat:@"%f", [_location lat]] forKey:@"latitude"];
	[info setObject:[NSString stringWithFormat:@"%f", [_location lon]] forKey:@"longitude"];
	
	NSMutableDictionary* pingObj = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
	[pingObj setObject:info forKey:@"ping"];
	
	NSLog(@"Ping data : %@", [pingObj JSONRepresentation]);
	
	// send ping

	ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
	[request setRequestMethod:@"POST"];
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request appendPostData: [[pingObj JSONRepresentation] dataUsingEncoding: NSUTF8StringEncoding]];
	[request startAsynchronous];
	
}

@end

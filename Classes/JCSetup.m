//
//  JCSetup.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCSetup.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"


@implementation JCSetup


+(JCSetup*) instance {
	static JCSetup *singleton = nil;
	
	if (singleton == nil) {
		singleton = [[JCSetup alloc] init];
	}
	return singleton;
}


- (void) configureJiraConnect:(NSURL*) withUrl {

    [[CrashReportSender sharedCrashReportSender] sendCrashReportToURL:withUrl
                                                             delegate:self 
                                                     activateFeedback:YES];
	
	NSLog(@"OI JC is Configured with url: %@", withUrl);
	
	[self sendPing];
}


-(NSString*) crashReportUserID {
	return [[UIDevice currentDevice] uniqueIdentifier];
	
}

-(NSString*) crashReportContact {
	return @"Contact - TODO";
}

-(NSString*) crashReportDescription {
	return @"Description - TODO";
}

- (void) sendPing {
	UIDevice* device = [UIDevice currentDevice];
	NSDictionary* appMetaData = [[NSBundle mainBundle] infoDictionary];
	
	
	NSMutableDictionary* info = [[NSMutableDictionary alloc] initWithCapacity:20];
	
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
	
	NSMutableDictionary* pingObj = [[NSMutableDictionary alloc] initWithCapacity:1];
	[pingObj setObject:info forKey:@"ping"];
	
	NSLog(@"Ping data : %@", [pingObj JSONRepresentation]);
	
	// send ping
	NSURL* url = [NSURL URLWithString:@"http://localhost:2990/jira/rest/jconnect/latest/ping"]; 	// todo: replace hard coded url
	ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
	[request setRequestMethod:@"POST"];
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request appendPostData: [[pingObj JSONRepresentation] dataUsingEncoding: NSUTF8StringEncoding]];
	[request startAsynchronous];
}

@end

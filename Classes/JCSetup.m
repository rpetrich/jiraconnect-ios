//
//  JCSetup.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCSetup.h"
#import "JCPing.h"
#import "JCCreateViewController.h"
#import "JCLocation.h"
#import "JCNotifier.h"


@implementation JCSetup

@synthesize url=_url;

JCPing* pinger;
JCNotifier* notifier;
JCCreateViewController *jcController;
JCLocation* _location;

-(void) dealloc {
	[super dealloc];
	[_url release];
	[pinger release];
	[notifier release];
	[jcController release];
	_url, 
	jcController,
	pinger = nil;
}

+(JCSetup*) instance {
	static JCSetup *singleton = nil;
	
	if (singleton == nil) {
		singleton = [[JCSetup alloc] init];
	}
	return singleton;
}

- (id)init {
	if (self = [super init]) {
		_location = [[[JCLocation alloc] init] retain];
		pinger = [[[JCPing alloc] initWithLocator:_location] retain];
		notifier = [[[JCNotifier alloc] init] retain];
		jcController = [[[JCCreateViewController alloc] initWithNibName:@"JCCreateViewController" bundle:nil] retain];
	}
	return self;
}

- (void) configureJiraConnect:(NSURL*) withUrl {

    [[CrashReportSender sharedCrashReportSender] sendCrashReportToURL:withUrl
                                                             delegate:self 
                                                     activateFeedback:YES];
	self.url = withUrl;
	[pinger startPinging:withUrl];
	
	NSLog(@"JiraConnect is Configured with url: %@", withUrl);
	
}

-(JCCreateViewController*) viewController {
	return jcController;
}

-(NSDictionary*) getMetaData {
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
	return info;
	
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


@end

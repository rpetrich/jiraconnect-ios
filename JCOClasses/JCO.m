//
//  JCO.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCO.h"
#import "JCPing.h"
#import "JCNotifier.h"
#import "JCOCrashSender.h"


@implementation JCO

@synthesize url=_url;

JCPing* _pinger;
JCNotifier* _notifier;
JCOViewController* _jcController;
JCOCrashSender* _crashSender;

+(JCO*) instance {
	static JCO *singleton = nil;
	
	if (singleton == nil) {
		singleton = [[JCO alloc] init];
	}
	return singleton;
}

- (id)init {
	if ((self = [super init])) {
		_pinger = [[[JCPing alloc] init] retain];
		UIView* window = [[UIApplication sharedApplication] keyWindow]; // TODO: investigate other ways to present our replies dialog.
		_notifier = [[[JCNotifier alloc] initWithView:window] retain];
		_crashSender = [[[JCOCrashSender alloc] init] retain];
		_jcController = [[[JCOViewController alloc] initWithNibName:@"JCOViewController" bundle:nil] retain];
		
	}
	return self;
}


- (void) configureJiraConnect:(NSString*) withUrl {

	self.url = [NSURL URLWithString:withUrl];

	[_pinger sendPing:self.url];
//	[NSTimer scheduledTimerWithTimeInterval:3 target:_crashSender selector:@selector(sendCrashReports) userInfo:nil repeats:YES];
	
	NSLog(@"JiraConnect is Configured with url: %@", withUrl);	
}


-(JCOViewController*) viewController {
	return _jcController;
}

-(void) displayNotifications {
    [_notifier displayNotifications:nil];
}

-(NSDictionary*) getMetaData {
	UIDevice* device = [UIDevice currentDevice];
	NSDictionary* appMetaData = [[NSBundle mainBundle] infoDictionary];
	NSMutableDictionary* info = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
	
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
	
	return info;
}

-(void) dealloc {
	[_url release]; _url = nil;
	[_pinger release]; _pinger = nil;
	[_notifier release]; _notifier = nil;
	[_jcController release]; _jcController = nil;
	[_crashSender release]; _crashSender = nil;
	[super dealloc];
}


@end

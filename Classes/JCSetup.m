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
#import "JCNotifier.h"


@implementation JCSetup

@synthesize url=_url;

JCPing* pinger;
JCNotifier* notifier;
JCCreateViewController *jcController;

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
		pinger = [[[JCPing alloc] init] retain];
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

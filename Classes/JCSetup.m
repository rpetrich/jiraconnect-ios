//
//  JCSetup.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCSetup.h"

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

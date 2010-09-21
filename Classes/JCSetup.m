//
//  JCSetup.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCSetup.h"
#import "CrashReportSender.h"

@implementation JCSetup



+ (void) configureJiraConnect:(NSURL*) withUrl {

    [[CrashReportSender sharedCrashReportSender] sendCrashReportToURL:withUrl
                                                             delegate:self 
                                                     activateFeedback:YES];
	
	NSLog(@"OI JC is Configured with url: %@", withUrl);
}




@end

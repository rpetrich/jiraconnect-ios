//
//  JCSetup.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCSetup.h"


@implementation JCSetup

void handleUncaughtException(NSException* exception) {
	NSArray *callStackArray = [exception callStackReturnAddresses];
	NSLog(@"Exception: %@ and callStack: %@", exception, callStackArray);
}


+ (void) configureJiraConnect:(NSURL*) withUrl {
	NSSetUncaughtExceptionHandler(&handleUncaughtException);
	NSLog(@"OI JC is Configured with url: %@", withUrl);
}




@end

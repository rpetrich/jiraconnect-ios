//
//  JCNotifications.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCNotifications.h"


@implementation JCNotifications

@synthesize notifications=_notifications;



-(void) dealloc {
	[super dealloc];
	[_notifications release];
	_notifications = nil;
	
}

@end

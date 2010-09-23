//
//  JCNotifier.m
//  JiraConnect
//
//  Created by Shihab Hamid on 23/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JCNotifier.h"

@implementation JCNotifier

- (void) dealloc {
	[_view release]; _view = nil;
	[_notifications release]; _notifications = nil;
	[super dealloc];
}

- (id) initWithView:(UIView*)parentView notifications:(JCNotifications*)notifications {
	if (self = [super init]) {
		_view = [parentView retain];
		_notifications = [notifications retain];
		
		// hack
		[_notifications add:@"some crap"];
		
		[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(notify:) userInfo:nil repeats:YES];
	}
	return self;
}

- (void) notify:(NSTimer*) timer {
	// check notifications
	if ([_notifications hasNotifications]) {
		NSLog(@"got notifications");
	}
}
	

@end

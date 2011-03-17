//
//  JCNotifications.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCNotifications.h"


@implementation JCNotifications

- (void) dealloc {
	[_notifications release]; _notifications = nil;
	[super dealloc];
}

- (id) init {
	if ((self = [super init])) {
		_notifications = [[[NSMutableArray alloc] init] retain];
	}
	return self;
}

- (NSArray*) readAndClear {
	NSArray* clone = [NSArray arrayWithArray:_notifications];
	[_notifications removeAllObjects];
	return clone;
}

- (void) add:(NSString*)message {
	[_notifications addObject:message];
}

- (NSInteger) notificationCount {
	return [_notifications count];
}

@end

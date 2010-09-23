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
		[_notifications add:@"No, you can't have a pony."];
		
		[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(notify:) userInfo:nil repeats:YES];
	}
	return self;
}

- (void) notify:(NSTimer*) timer {
	// check notifications
	if ([_notifications hasNotifications]) {
		NSArray* notes = [_notifications readAndClear];
		NSLog(@"got %d notification(s)", [notes count]);
		
		NSString* msg = @"STUFF";
		
		/*
		UIActionSheet* alert = [[[UIActionSheet alloc] 
							   initWithTitle:msg 
							   delegate:nil 
							   cancelButtonTitle:@"Dismiss"  destructiveButtonTitle:nil 
							   otherButtonTitles:@"View", nil] 
							  autorelease];
		[alert showInView:_view];
		 */
		
		UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 520, 320, 40)];
		[toolbar setBarStyle:UIBarStyleBlack];
		[toolbar setTranslucent:YES];
		UILabel* toolBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
		toolBarLabel.text = @"1 new notification from developer";
		[toolbar addSubview:toolBarLabel];
								 
		
		[_view addSubview:toolbar];
		
		[UIView beginAnimations:@"animateToolbar" context:nil];
		[UIView setAnimationDuration:0.4];
		[toolbar setFrame:CGRectMake(0, 440, 320, 40)]; //notice this is ON screen!
		[UIView commitAnimations];						
	}
}
	

@end

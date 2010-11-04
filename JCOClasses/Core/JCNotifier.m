//
//  JCNotifier.m
//  JiraConnect
//
//  Created by Shihab Hamid on 23/09/10.
//  Copyright 2010 Atlassian . All rights reserved.
//

#import "JCNotifier.h"
#import "JCNotificationViewController.h"
#import "JCO.h"

@implementation JCNotifier

- (void) dealloc {
	[_view release]; _view = nil;
	[_notifications release]; _notifications = nil;
	[_viewController release]; _viewController = nil;
	[_label release]; _label = nil;
	[_toolbar release]; _toolbar = nil;
	[_button release]; _button = nil;
	[super dealloc];
}

- (id) initWithView:(UIView*)parentView notifications:(JCNotifications*)notifications {
	if (self = [super init]) {
		_view = [parentView retain];
		_notifications = [notifications retain];
		_viewController = [[JCNotificationViewController alloc] initWithNibName:@"JCNotificationViewController" bundle:nil];
		_viewController.view;
		
		_toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 520, 320, 40)];
		[_toolbar setBarStyle:UIBarStyleBlack];
		[_toolbar setTranslucent:YES];
		
		_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 20)];
		_label.backgroundColor = [UIColor clearColor];
		_label.textAlignment =  UITextAlignmentCenter;
		_label.textColor = [UIColor whiteColor];
		[_toolbar addSubview:_label];	
		
		_button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[_button setFrame:CGRectMake(0, 440, 320, 40)];	
		[_button addTarget:self action:@selector(displayNotifications:) forControlEvents:UIControlEventTouchUpInside];
		
		// hack
		//[_notifications add:@"No, you can't have a pony."];
		
		[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(notify:) userInfo:nil repeats:YES];
	}
	return self;
}

- (void) notify:(NSTimer*) timer {
	// check notifications
	if ([_notifications notificationCount] > 0) {
		NSArray* notes = [_notifications readAndClear];
		NSLog(@"got %d notification(s)", [notes count]);
		
		/*
		UIActionSheet* alert = [[[UIActionSheet alloc] 
							   initWithTitle:msg 
							   delegate:nil 
							   cancelButtonTitle:@"Dismiss"  destructiveButtonTitle:nil 
							   otherButtonTitles:@"View", nil] 
							  autorelease];
		[alert showInView:_view];
		 */
		
		_label.text = [NSString stringWithFormat:@"%d new notification from developer", [notes count]];
		NSString* text = [notes objectAtIndex:0]; // TODO FIX HACK OR GET TIM TO SEND A SINGLE STRING
		NSLog(@"Notification: %@", text);
		[_viewController.textView setText:text];
		
		[_toolbar setFrame:CGRectMake(0, 520, 320, 40)];
		[_view addSubview:_toolbar];

		[UIView beginAnimations:@"animateToolbar" context:nil];
		[UIView setAnimationDuration:0.4];
		[_toolbar setFrame:CGRectMake(0, 440, 320, 40)]; //notice this is ON screen!
		[UIView commitAnimations];
			
		[_view addSubview:_button];	
	}
}

- (void)displayNotifications:(id)sender {
	[_viewController.view setFrame:CGRectMake(0, 480, 320, 480)];
	[_view addSubview:_viewController.view];
	
	[UIView beginAnimations:@"animateView" context:nil];
	[UIView setAnimationDuration:0.4];
	[_viewController.view setFrame:CGRectMake(0, 20, 320, 480)]; //notice this is ON screen!
	[UIView commitAnimations];	
	
	[_button removeFromSuperview];
	[_toolbar removeFromSuperview];
}
	

@end

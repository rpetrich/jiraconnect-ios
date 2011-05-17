//
//  JCONotifier.m
//  JiraConnect
//
//  Created by Shihab Hamid on 23/09/10.
//

#import "JCONotifier.h"
#import "JCOIssueStore.h"

@implementation JCONotifier

- (id)initWithView:(UIView *)parentView {
	if ((self = [super init])) {
        
        NSLog(@"ParentView: %@", parentView);
        
		_view = [parentView retain];

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify:) name:@"JCODidReceiveIssueCommentsNotification" object:nil];
    }
	return self;
}

- (void) notify:(NSTimer*) timer {
	// check notifications

    //hack -> for now always show that there is 1 notification
//	if ([JCOIssueStore instance].newIssueCount > 0) {
	if ([JCOIssueStore instance].issues) {
		_label.text = [NSString stringWithFormat:@"%d new notification from developer", [JCOIssueStore instance].newIssueCount];
		
        JCOIssuesViewController * tableViewController = [[JCOIssuesViewController alloc] initWithNibName:@"JCOIssuesViewController" bundle:nil];
		[tableViewController loadView];        
        
        NSArray* data;
        NSArray* headers;
        data = [NSArray arrayWithObjects:[[JCOIssueStore instance] issues], nil];
        headers = [NSArray arrayWithObjects:@"Feedback",  nil];
        
		[tableViewController setData:data];
        [tableViewController setHeaders:headers];
        
        _viewController = [[UINavigationController alloc] initWithRootViewController:tableViewController];

        [tableViewController release];
		
        NSLog(@"View: %@", _view);		
        
		[_toolbar setFrame:CGRectMake(0, 520, 320, 40)];
		[_view addSubview:_toolbar];

		[UIView beginAnimations:@"animateToolbar" context:nil];
		[UIView setAnimationDuration:0.4];
		[_toolbar setFrame:CGRectMake(0, 440, 320, 40)]; //notice this is ON screen!
		[UIView commitAnimations];
			
		[_view addSubview:_button];	
	} else {
        NSLog(@"No notices to display");
        
    }
}

- (void)displayNotifications:(id)sender {
	[_viewController.view setFrame:CGRectMake(0, 480, 320, 480)];
	[_view addSubview:_viewController.view];
	
    
	[UIView beginAnimations:@"animateView" context:nil];
	[UIView setAnimationDuration:0.4];
	[_viewController.view setFrame:CGRectMake(0, 0, 320, 480)]; //notice this is ON screen!
	[UIView commitAnimations];	
	
	[_button removeFromSuperview];
	[_toolbar removeFromSuperview];
}

- (void) dealloc {

	[_view release]; _view = nil;
	[_viewController release]; _viewController = nil;
	[_label release]; _label = nil;
	[_toolbar release]; _toolbar = nil;
	[_button release]; _button = nil;
	[super dealloc];
}

@end

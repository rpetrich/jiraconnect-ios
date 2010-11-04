//
//  JCNotificationViewController.m
//  JiraConnect
//
//  Created by Shihab Hamid on 23/09/10.
//  Copyright 2010 Atlassian . All rights reserved.
//

#import "JCNotificationViewController.h"
#import "JCO.h"

@implementation JCNotificationViewController

@synthesize textView=_textView;

- (IBAction) dismiss:(id)sender {
	[UIView beginAnimations:@"dismissView" context:nil];
	[UIView setAnimationDuration:0.4];
	[self.view setFrame:CGRectMake(0, 480, 320, 480)]; //notice this is ON screen!
	[UIView commitAnimations];	
	
	[self performSelector:@selector(removeView) withObject:nil afterDelay:0.4];
}

- (IBAction) reply:(id)sender {
	JCOViewController* controller = [[JCO instance] viewController];
	controller.descriptionField.text = @"";
	[controller.screenshotButton setBackgroundImage:nil forState:UIControlStateNormal];
	[self presentModalViewController:[[JCO instance] viewController] animated:YES];
}

- (void)removeView {
	[self.view removeFromSuperview];
}



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

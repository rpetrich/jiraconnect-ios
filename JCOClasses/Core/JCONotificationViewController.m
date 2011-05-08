//
//  JCONotificationViewController.m
//  JiraConnect
//
//  Created by Shihab Hamid on 23/09/10.
//

#import "JCONotificationViewController.h"
#import "JCO.h"

@implementation JCONotificationViewController

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

- (void)dealloc {
    self.textView = nil;
    [super dealloc];
}


@end

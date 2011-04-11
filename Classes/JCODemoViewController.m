
#import "JCODemoViewController.h"
#import "JCO.h"
#import "JCOPayloadDataSource.h"

@implementation JCODemoViewController

@synthesize triggerButtonCrash, triggerButtonFeedback, triggerButtonNotifications;


- (IBAction) triggerFeedback {
	NSLog(@"FEEEDBACK");
	JCOViewController* controller = [[JCO instance] viewController];
    controller.payloadDataSource = self;

	[self presentModalViewController:controller animated:YES];
}

- (IBAction) triggerCrash
{
	NSLog(@"Trigger crash!");
	/* Trigger a crash */
	CFRelease(NULL);
}

- (NSDictionary *)payloadFor:(NSString *)issueTitle {
    return [NSDictionary dictionaryWithObject:@"CUSTOM VALUE" forKey:@"CUSTOM KEY"];
}


- (IBAction) triggerDisplayNotifications {
    NSLog(@"Trigger notifications");
    [[JCO instance] displayNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    self.triggerButtonCrash, self.triggerButtonFeedback, self.triggerButtonNotifications = nil;
    [super dealloc];
}

@end

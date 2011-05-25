
#import <UIKit/UIKit.h>

#import "AngryNerdsViewController.h"

@interface JiraConnectAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AngryNerdsViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AngryNerdsViewController *viewController;

@end


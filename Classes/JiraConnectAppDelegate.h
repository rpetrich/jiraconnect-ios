//
//  JiraConnectAppDelegate.h
//  JiraConnect
//
//  Created by Nick Pellow on 3/11/10.
//

#import <UIKit/UIKit.h>

@class AngryNerdsViewController;

@interface JiraConnectAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AngryNerdsViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AngryNerdsViewController *viewController;

@end


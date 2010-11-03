//
//  JiraConnectAppDelegate.h
//  JiraConnect
//
//  Created by Nick Pellow on 3/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCODemoViewController;

@interface JiraConnectAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    JCODemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet JCODemoViewController *viewController;

@end


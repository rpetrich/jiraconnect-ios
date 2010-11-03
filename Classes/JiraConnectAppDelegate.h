//
//  JiraConnectAppDelegate.h
//  JiraConnect
//
//  Created by Nick Pellow on 3/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JiraConnectViewController;

@interface JiraConnectAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    JiraConnectViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet JiraConnectViewController *viewController;

@end


//
//  JiraConnectAppDelegate.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrashReporterDemoViewController.h"

@class CrashReporterDemoViewController;

@interface JiraConnectAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CrashReporterDemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CrashReporterDemoViewController *viewController;

@end


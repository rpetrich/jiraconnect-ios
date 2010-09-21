//
//  JiraConnectAppDelegate.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrashReportSender.h"

@class JiraConnectViewController;

@interface JiraConnectAppDelegate : NSObject <UIApplicationDelegate, CrashReportSenderDelegate> {
    UIWindow *window;
    JiraConnectViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet JiraConnectViewController *viewController;

@end


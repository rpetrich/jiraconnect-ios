//
//  JCNotifier.h
//  JiraConnect
//
//  Created by Shihab Hamid on 23/09/10.
//  Copyright 2010 Atlassian . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCNotifications.h"
#import "JCNotificationViewController.h"

@interface JCNotifier : NSObject {
	UIView* _view;
	JCNotifications* _notifications;
	JCNotificationViewController* _viewController;
	UIToolbar* _toolbar;
	UILabel* _label;
	UIButton* _button;
}

- (id) initWithView:(UIView*)parentView notifications:(JCNotifications*)notifications;

@end

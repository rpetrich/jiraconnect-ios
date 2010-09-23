//
//  JCNotifier.h
//  JiraConnect
//
//  Created by Shihab Hamid on 23/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCNotifications.h"

@interface JCNotifier : NSObject {
	UIView* _view;
	JCNotifications* _notifications;
}

- (id) initWithView:(UIView*)parentView notifications:(JCNotifications*)notifications;

@end

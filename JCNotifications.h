//
//  JCNotifications.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JCNotifications : NSObject {
	NSMutableArray* _notifications;
}

@property (nonatomic, retain) NSMutableArray* notifications;

@end

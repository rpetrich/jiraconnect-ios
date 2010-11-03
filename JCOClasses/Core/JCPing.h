//
//  JCPing.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "JCNotifications.h"
#import "JCLocation.h"

@interface JCPing : NSObject {
	JCLocation* _location;
	JCNotifications* _notifications;
}

- (id)initWithLocator:(JCLocation*) locator notifications:(JCNotifications*)notes;
- (void) startPinging:(NSURL*) url;

@end

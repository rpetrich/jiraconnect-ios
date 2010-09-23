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

@interface JCPing : NSObject {

}

- (void) startPinging:(NSURL*) url;

@end

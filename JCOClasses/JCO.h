//
//  JCO.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCOViewController.h"


@interface JCO : NSObject {
	NSURL* _url;	
}

@property (nonatomic, retain) NSURL* url;

+ (JCO*) instance;

- (void) configureJiraConnect:(NSURL*)url;
- (JCCreateViewController*) viewController;
- (NSDictionary*) getMetaData;

@end

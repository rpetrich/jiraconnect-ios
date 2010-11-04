//
//  JCO.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCOViewController.h"
#import "CrashReportSender.h"

@interface JCO : NSObject <CrashReportSenderDelegate> {
	NSURL* _url;	
	id<CrashReportSenderDelegate> senderDelegate;
}

@property (nonatomic, retain) NSURL* url;

+ (JCO*) instance;

- (void) configureJiraConnect:(NSURL*)url;
- (JCOViewController*) viewController;
- (NSDictionary*) getMetaData;

@end

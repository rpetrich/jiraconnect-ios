//
//  JCO.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//

#import <Foundation/Foundation.h>
#import "JCOViewController.h"
#import "CrashReporter.h"

@class JCONavigationController;

@interface JCO : NSObject {
	NSURL* _url;	
}

@property (nonatomic, retain) NSURL* url;

+ (JCO*) instance;

- (void) configureJiraConnect:(NSString*) withUrl customData:(id<JCOCustomDataSource>)customData;
- (UIViewController*) viewController;
- (void) displayNotifications;
- (NSDictionary*) getMetaData;
- (NSString*) getProjectName;

@end


#import <Foundation/Foundation.h>
#import "JCOViewController.h"
#import "CrashReporter.h"

#define kJIRAConnectUUID @"JIRAConnectUUID"

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
- (NSString *) getAppName;
- (NSString *) getUUID;

@end

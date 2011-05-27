
#import <Foundation/Foundation.h>
#import "JCOViewController.h"
#import "CrashReporter.h"

#define kJIRAConnectUUID @"kJIRAConnectUUID"
#define kJCOReceivedCommentsNotification @"kJCOReceivedCommentsNotification"
#define kJCOLastSuccessfulPingTime @"kJCOLastSuccessfulPingTime"

@interface JCO : NSObject {
	NSURL* _url;
}

@property (nonatomic, retain) NSURL* url;

+ (JCO*) instance;

- (void) configureJiraConnect:(NSString*) withUrl customData:(id<JCOCustomDataSource>)customData;
- (UIViewController*) viewController;
- (void) displayNotifications;
- (NSDictionary*) getMetaData;
- (NSString *) getProject;
- (NSString *) getAppName;
- (NSString *) getUUID;

@end

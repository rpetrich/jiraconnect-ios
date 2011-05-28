
#import <Foundation/Foundation.h>
#import "JCOViewController.h"
#import "CrashReporter.h"

@class JCOIssuesViewController;

#define kJIRAConnectUUID @"kJIRAConnectUUID"
#define kJCOReceivedCommentsNotification @"kJCOReceivedCommentsNotification"
#define kJCOLastSuccessfulPingTime @"kJCOLastSuccessfulPingTime"

@interface JCO : NSObject {
	NSURL* _url;
}

@property (nonatomic, retain) NSURL* url;

+ (JCO*) instance;

/**
* This method setups JIRAConnect for a specific JIRA instance.
* Call this method from your AppDelelegate, directly after the call to [window makeKeyAndVisible];.
* If custom data is required to be attached to each crash and issue report, then provide a JCOCustomDatSource. If
* no custom data is required, then pass in nil.
*/
- (void) configureJiraConnect:(NSString*) withUrl customData:(id<JCOCustomDataSource>)customData;

/**
* Retrieves the main viewController for JIRAConnect. This controller holds the 'create issue' view.
*/
- (UIViewController*) viewController;

/**
* The view controller which displays the list of all issues a user has raised for this app.
*/
- (UIViewController*) issuesViewController;

- (NSDictionary*) getMetaData;
- (NSString *) getProject;
- (NSString *) getAppName;
- (NSString *) getUUID;

@end

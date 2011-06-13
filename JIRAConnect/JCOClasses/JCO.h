
#import <Foundation/Foundation.h>
#import "JCOViewController.h"
#import "CrashReporter.h"

@class JCOIssuesViewController, JCOPing, JCONotifier, JCONotifier, JCOCrashSender;

#define kJIRAConnectUUID @"kJIRAConnectUUID"
#define kJCOReceivedCommentsNotification @"kJCOReceivedCommentsNotification"
#define kJCOLastSuccessfulPingTime @"kJCOLastSuccessfulPingTime"

@interface JCO : NSObject {
    @private
    NSURL* _url;
    JCOPing *_pinger;
    JCONotifier *_notifier;
    JCOViewController *_jcController;
    UINavigationController *_navController;
    JCOCrashSender *_crashSender;
    id <JCOCustomDataSource> _customDataSource;  
}

@property (nonatomic, retain) NSURL* url;

+ (JCO*) instance;

/**
* This method setups JIRAConnect for a specific JIRA instance.
* Call this method from your AppDelelegate, directly after the call to [window makeKeyAndVisible];.
* If custom data is required to be attached to each crash and issue report, then provide a JCOCustomDatSource. If
* no custom data is required, then pass in nil.
*/
- (void) configureJiraConnect:(NSString*) withUrl customDataSource:(id<JCOCustomDataSource>)customDataSource;

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

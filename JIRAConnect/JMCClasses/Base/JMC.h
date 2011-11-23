/**
   Copyright 2011 Atlassian Software

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
**/

#import <Foundation/Foundation.h>
#import "JMCViewController.h"
#import "CrashReporter.h"
#import "JMCAttachmentItem.h"
#import "JMCMacros.h"

@class JMCIssuesViewController, JMCPing, JMCNotifier, JMCNotifier, JMCCrashSender;

// Use this macro outside JMC to enable code that depends on JMC
#define JMC_PRESENT

// Constants
#define kJIRAConnectUUID @"kJIRAConnectUUID"
#define kJMCReceivedCommentsNotification @"kJMCReceivedCommentsNotification"
#define kJMCLastSuccessfulPingTime @"kJMCLastSuccessfulPingTime"
#define kJMCIssueUpdated @"kJMCIssueUpdated"
#define kJMCNewCommentCreated @"kJMCNewCommentCreated"

#define kJMCOptionUrl @"kJMCOptionUrl"
#define kJMCOptionProjectKey @"kJMCOptionProjectKey"
#define kJMCOptionApiKey @"kJMCOptionApiKey"
#define kJMCOptionPhotosEnabled @"kJMCOptionPhotosEnabled"
#define kJMCOptionVoiceEnabled @"kJMCOptionVoiceEnabled"
#define kJMCOptionLocationEnabled @"kJMCOptionLocationEnabled"
#define kJMCOptionCrashReportingEnabled @"kJMCOptionCrashReportingEnabled"
#define kJMCOptionCustomFields @"kJMCOptionCustomFields"
#define kJMCOptionUIBarStyle @"kJMCOptionUIBarStyle"

@interface JMCOptions : NSObject {
    NSString* _url;
    NSString* _projectKey;
    NSString* _apiKey;
    BOOL _photosEnabled;
    BOOL _voiceEnabled;
    BOOL _locationEnabled;
    BOOL _crashReportingEnabled;
    NSDictionary* _customFields;
    UIBarStyle _barStyle;
}

+(id) optionsWithContentsOfFile:(NSString *)filePath;
+(id) optionsWithUrl:(NSString *)jiraUrl
            projectKey:(NSString*)projectKey
             apiKey:(NSString*)apiKey
             photos:(BOOL)photos
              voice:(BOOL)voice
           location:(BOOL)location
       crashReporting:(BOOL)crashreporting
       customFields:(NSDictionary*)customFields;

/**
* The base URL of the JIRA instance.
* e.g. http://connect.onjira.com
*/
@property (retain, nonatomic) NSString* url;

/**
* If non-nil, use this project name when creating feedback. Otherwise, the bundle name is used.
* This value can be either the JIRA Project's name, _or_ its Project Key. e.g. CONNECT
*/
@property (retain) NSString* projectKey;

/**
* This is required to talk to JIRA.
* A API Key exists per JIRA project. see also http://developer.atlassian.com/x/J4VW
*/
@property (retain) NSString* apiKey;

/**
 * If YES users will be able to submit screenshots/photos with their feedback, this is YES by default.
 */
@property (assign) BOOL photosEnabled;

/**
 * If YES users will be able to submit voice recordings with their feedback, this is YES by default.
 */
@property (assign) BOOL voiceEnabled;

/**
 * If YES the location data (lat/lng) will be sent as a part of the issue, this is NO by default.
 */
@property (assign) BOOL locationEnabled;

/**
 * If YES, Crash Reports will be submitted directly to JIRA. Set this to NO if you don't wish to collect crash reports
 * or are collecting Crash Reports via some other means.
 */
@property (assign) BOOL crashReportingEnabled;

/**
* A dicitonary mapping custom field names to custom field values.
* If the JIRA instance contains a custom field of the same name, then the value will be used
* when creating any issues.
*/
@property (retain) NSDictionary* customFields;

/**
 * The style to use for all navigation bars.
 */
@property (assign) UIBarStyle barStyle;

@end

@interface JMC : NSObject {
    @private
    NSURL* _url;
    JMCPing *_pinger;
    JMCNotifier *_notifier;
    JMCCrashSender *_crashSender;
    id <JMCCustomDataSource> _customDataSource;
    JMCOptions* _options;
}

enum JMCViewControllerMode {
  JMCViewControllerModeDefault,
  JMCViewControllerModeCustom
};

@property (nonatomic, assign) id <JMCCustomDataSource> customDataSource;
@property (nonatomic, retain) JMCOptions* options;
@property (readonly) NSURL* url;

+ (JMC *) instance;

/**
* This method setups JIRAConnect for a specific JIRA instance.
* Call this method from your AppDelelegate during the application:didFinishLaunchingWithOptions method.
* If custom data is required to be attached to each crash and issue report, then provide a JMCCustomDatSource. If
* no custom data is required, then pass in nil.
*/
- (void) configureJiraConnect:(NSString*) withUrl customDataSource:(id<JMCCustomDataSource>)customDataSource;
- (void) configureJiraConnect:(NSString*) withUrl projectKey:(NSString*)project apiKey:(NSString *)apiKey;
- (void) configureJiraConnect:(NSString*) withUrl
                   projectKey:(NSString*) project
                       apiKey:(NSString *)apiKey
                   dataSource:(id<JMCCustomDataSource>)customDataSource;
- (void) configureJiraConnect:(NSString*) withUrl
                   projectKey:(NSString*) project
                       apiKey:(NSString *)apiKey
                     location:(BOOL) locationEnabled
                   dataSource:(id<JMCCustomDataSource>)customDataSource;

- (void) configureWithOptions:(JMCOptions*)options;
- (void) configureWithOptions:(JMCOptions*)options dataSource:(id<JMCCustomDataSource>)customDataSource;

/**
 * This method should not be called if any of the configureXXX methods above are called.
 * Only call start if none of the configureXXX methods were called.
 */
-(void) start;
-(void) flushRequestQueue;

/**
* Retrieves the 'correct' viewController to present to the user.
*  * If the user has previously created feedback, the inbox is returned.
*  * If the user has not yet left any feedback, the feedbackViewController is returned.
*/
- (UIViewController*) viewController;
- (UIViewController*) viewControllerWithMode:(enum JMCViewControllerMode)mode;

/**
* Retrieves the feedback viewController for JIRAConnect. This controller holds the 'create issue' view.
*/
- (UIViewController*) feedbackViewController;
- (UIViewController*) feedbackViewControllerWithMode:(enum JMCViewControllerMode)mode;

/**
* The view controller which displays the list of all issues a user has raised for this app.
*/
- (UIViewController*) issuesViewController;
- (UIViewController*) issuesViewControllerWithMode:(enum JMCViewControllerMode)mode;

/**
 * This is a generic icon that can be used in your App as the icon for Feedback.
 */
-(UIImage*) feedbackIcon;

- (NSDictionary*) getMetaData;
- (NSMutableDictionary*) getCustomFields;
- (NSArray *) components;
- (NSString *) getProject;
- (NSString *) getApiKey;
- (NSString *) getAppName;
- (NSString *) getUUID;
- (NSString *) getAPIVersion;
- (UIBarStyle) getBarStyle;

- (BOOL) isPhotosEnabled;
- (BOOL) isVoiceEnabled;
- (BOOL) isLocationEnabled;
- (NSString*) issueTypeNameFor:(JMCIssueType)type useDefault:(NSString *)defaultType;

/** The path that JMC uses to store its data: local DB cache, and offline request queue. **/
- (NSString *)dataDirPath;

@end

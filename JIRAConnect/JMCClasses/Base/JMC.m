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
#import "JMC.h"
#import "JMCPing.h"
#import "JMCNotifier.h"
#import "JMCCrashSender.h"
#import "JMCCreateIssueDelegate.h"
#import "JMCRequestQueue.h"
#import "JMCIssuesViewController.h"
#include <sys/xattr.h>

@implementation JMCOptions
@synthesize url=_url, projectKey=_projectKey, apiKey=_apiKey,
            photosEnabled=_photosEnabled, voiceEnabled=_voiceEnabled, locationEnabled=_locationEnabled,
            crashReportingEnabled=_crashReportingEnabled, notificationsEnabled=_notificationsEnabled, barStyle=_barStyle,
            customFields=_customFields, modalPresentationStyle=_modalPresentationStyle;

-(id)init
{
    if ((self = [super init])) {
        _photosEnabled = YES;
        _voiceEnabled = YES;
        _locationEnabled = NO;
        _crashReportingEnabled = YES;
        _notificationsEnabled = YES;
        _barStyle = UIBarStyleDefault;
        _modalPresentationStyle = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) ? 
                                    UIModalPresentationFormSheet : UIModalPresentationFullScreen;
    }
    return self;
}

+(id)optionsWithContentsOfFile:(NSString *)filePath
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    JMCOptions* options = [[[JMCOptions alloc] init]autorelease];
    options.url = [dict objectForKey:kJMCOptionUrl];
    options.projectKey = [dict objectForKey:kJMCOptionProjectKey];
    options.apiKey = [dict objectForKey:kJMCOptionApiKey];
    options.photosEnabled = [[dict objectForKey:kJMCOptionPhotosEnabled] boolValue];
    options.voiceEnabled = [[dict objectForKey:kJMCOptionVoiceEnabled] boolValue];
    options.locationEnabled = [[dict objectForKey:kJMCOptionLocationEnabled] boolValue];
    options.crashReportingEnabled = [[dict objectForKey:kJMCOptionCrashReportingEnabled] boolValue];
    options.notificationsEnabled = [[dict objectForKey:kJMCOptionNotificationsEnabled] boolValue];
    options.customFields = [dict objectForKey:kJMCOptionCustomFields];
    options.barStyle = [[dict objectForKey:kJMCOptionUIBarStyle] intValue];
    options.modalPresentationStyle = [[dict objectForKey:kJMCOptionUIModalPresentationStyle] intValue];
    return options;
}

+(id)optionsWithUrl:(NSString *)jiraUrl
            projectKey:(NSString*)projectKey
             apiKey:(NSString*)apiKey
             photos:(BOOL)photos
              voice:(BOOL)voice
           location:(BOOL)location
     crashReporting:(BOOL)crashreporting
      notifications:(BOOL)notifications
       customFields:(NSDictionary*)customFields
{
    JMCOptions* options = [[[JMCOptions alloc] init]autorelease];
    options.url = jiraUrl;
    options.projectKey = projectKey;
    options.apiKey = apiKey;
    options.photosEnabled = photos;
    options.voiceEnabled = voice;
    options.locationEnabled = location;
    options.crashReportingEnabled = crashreporting;
    options.customFields = customFields;
    return options;
}

- (id)copyWithZone:(NSZone *)zone
{
    JMCOptions* copy = [[JMCOptions alloc] init];
    copy.url = self.url;
    copy.projectKey = self.projectKey;
    copy.apiKey = self.apiKey;
    copy.photosEnabled = self.photosEnabled;
    copy.voiceEnabled = self.voiceEnabled;
    copy.locationEnabled = self.locationEnabled;
    copy.crashReportingEnabled = self.crashReportingEnabled;
    copy.notificationsEnabled = self.notificationsEnabled;
    copy.customFields = self.customFields;
    copy.barStyle = self.barStyle;
    copy.modalPresentationStyle = self.modalPresentationStyle;
    return copy;
}


-(void)setUrl:(NSString*)url
{
    unichar lastChar = [url characterAtIndex:[url length] - 1];
    // if the lastChar is not a /, then add a /
    NSString* charToAppend = lastChar != '/' ? @"/" : @"";
    url = [url stringByAppendingString:charToAppend];

    [_url autorelease];
    _url = [url retain];
}

-(void) dealloc
{
    self.url = nil;
    self.projectKey = nil;
    self.apiKey = nil;
    self.customFields = nil;
    [super dealloc];
}

@end


@interface JMC ()

@property (nonatomic, retain) JMCPing * _pinger;
@property (nonatomic, retain) JMCNotifier * _notifier;
@property (nonatomic, retain) JMCCrashSender *_crashSender;
@property (nonatomic, retain) NSString* _dataDirPath;


-(CGRect)notifierStartFrame;
-(CGRect)notifierEndFrame;
- (NSString *)makeDataDirPath;
- (void)generateAndStoreUUID;
@end

static BOOL started;
static JMCViewController* _jcViewController;

@implementation JMC

@synthesize customDataSource=_customDataSource;
@synthesize options=_options;
@synthesize url=_url;
@synthesize _pinger;
@synthesize _notifier;
@synthesize _crashSender;
@synthesize _dataDirPath;

+ (JMC *)instance
{
    static JMC *singleton = nil;
    
    if (singleton == nil) {
        singleton = [[JMC alloc] init];
        started = NO;
    }
    return singleton;
}

- (void)dealloc
{
    self.options = nil;
    self.customDataSource = nil;
    [_pinger release];
    [_notifier release];
    [_crashSender release];
    [_dataDirPath release];
    [_jcViewController release];
    [super dealloc];
}

-(id)init
{
    if ((self = [super init])) {
        JMCOptions* options = [[JMCOptions alloc] init];
        self.options = options;
        [options release];
        
        self._dataDirPath = [self makeDataDirPath];
        
        [self generateAndStoreUUID];

    }
    return self;
}


// TODO: call this when network becomes active after app becomes active
-(void)flushRequestQueue
{
    [[JMCRequestQueue sharedInstance] flushQueue];
}


- (void)generateAndStoreUUID
{
    // generate and store a UUID if none exists already
    if ([self getUUID] == nil) {
        
        NSString *uuid = nil;
        CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
        if (theUUID) {
            uuid = NSMakeCollectable(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
            CFRelease(theUUID);
            [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:kJIRAConnectUUID];
            CFRelease(uuid);
        }
    }
}

- (void) configureJiraConnect:(NSString*) withUrl projectKey:(NSString*)project apiKey:(NSString *)apiKey
{
    JMCOptions *options = [self.options copy];
    options.url = withUrl;
    options.projectKey = project;
    options.apiKey = apiKey;
    [self configureWithOptions:options];
    [options release];
}

- (void) configureJiraConnect:(NSString*) withUrl
                   projectKey:(NSString*)project
                       apiKey:(NSString *)apiKey
                   dataSource:(id<JMCCustomDataSource>)customDataSource
{
    JMCOptions *options = [self.options copy];
    options.url = withUrl;
    options.projectKey = project;
    options.apiKey = apiKey;
    [self configureWithOptions:options dataSource:customDataSource];
    [options release];
}

- (void) configureJiraConnect:(NSString*) withUrl
                   projectKey:(NSString*) project
                       apiKey:(NSString *)apiKey
                     location:(BOOL) locationEnabled
                   dataSource:(id<JMCCustomDataSource>)customDataSource
{
    JMCOptions *options = [self.options copy];
    options.url = withUrl;
    options.projectKey = project;
    options.apiKey = apiKey;
    options.locationEnabled = locationEnabled;
    [self configureWithOptions:options dataSource:customDataSource];
    [options release];
}

- (void) configureWithOptions:(JMCOptions*)options
{
    [self configureWithOptions:options dataSource:nil];
}

- (void) configureWithOptions:(JMCOptions*)options dataSource:(id<JMCCustomDataSource>)customDataSource
{
    self.options = options;
  
    [self configureJiraConnect:options.url customDataSource:customDataSource];
}

- (void)configureJiraConnect:(NSString *)withUrl customDataSource:(id <JMCCustomDataSource>)customDataSource
{
    self.options.url = withUrl;
    self.customDataSource = customDataSource;
    [self start];
}

-(void) start 
{
    if (self.options.crashReportingEnabled) {
        self._crashSender = [[[JMCCrashSender alloc] init] autorelease ];
        [CrashReporter enableCrashReporter];
        // TODO: firing this when network becomes active could be better
        [NSTimer scheduledTimerWithTimeInterval:3
                                         target:_crashSender
                                       selector:@selector(promptThenMaybeSendCrashReports)
                                       userInfo:nil repeats:NO];
    }


    if (self.options.notificationsEnabled) {

        self._pinger = [[[JMCPing alloc] init] autorelease ];
        JMCNotifier* notifier = [[JMCNotifier alloc] initWithStartFrame:[self notifierStartFrame]
                                                               endFrame:[self notifierEndFrame]];
        self._notifier = notifier;
        [notifier release];
        // whenever the Application Becomes Active, ping for notifications from JIRA.
        [[NSNotificationCenter defaultCenter] removeObserver:_pinger]; // in case app was already configured, don't add a second observer.
        [[NSNotificationCenter defaultCenter] addObserver:_pinger
                                                 selector:@selector(start)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    } else {
        JMCDLog(@"Notifications are disabled.");
    }
    started = YES;
    
    JMCDLog(@"JIRA Mobile Connect is configured with url: %@", self.url);
}

-(NSURL*)url
{
    return self.options.url ? [NSURL URLWithString:self.options.url] : nil;
}

-(JMCViewController*)initJMCViewController
{
    return [[JMCViewController alloc] initWithNibName:@"JMCViewController" bundle:nil];
}

- (JMCViewController *)_jcController {
    if (_jcViewController == nil) {

        _jcViewController = [[self initJMCViewController] retain];
        _jcViewController.modalPresentationStyle = self.options.modalPresentationStyle;
    }
    return _jcViewController;
    
}

- (JMCIssuesViewController *)_issuesController {
    JMCIssuesViewController *viewController = [[[JMCIssuesViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    [viewController loadView];
    [viewController setIssueStore:[JMCIssueStore instance]];
    viewController.modalPresentationStyle = self.options.modalPresentationStyle;
    return viewController;
}

- (UIViewController *)viewController
{
    return [self viewControllerWithMode:JMCViewControllerModeDefault];
}

- (UIViewController *)viewControllerWithMode:(enum JMCViewControllerMode)mode 
{
    if ([JMCIssueStore instance].count > 0) {
        return [self issuesViewControllerWithMode:mode];
    } else {
        return [self feedbackViewControllerWithMode:mode];
    }
}

- (UIViewController *)feedbackViewController
{
    return [self feedbackViewControllerWithMode:JMCViewControllerModeDefault];
}

- (UIViewController *)feedbackViewControllerWithMode:(enum JMCViewControllerMode)mode {
    if (mode == JMCViewControllerModeCustom) {
        return [[self initJMCViewController] autorelease]; // customview modes get a clean JMCViewController
    }
    else { // standard re-uses the same
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:[self _jcController]] autorelease];
        navigationController.navigationBar.barStyle =  self.options.barStyle;
        navigationController.modalPresentationStyle = self.options.modalPresentationStyle;
        return navigationController;
    }
}

- (UIViewController *)issuesViewController
{
    return [self issuesViewControllerWithMode:JMCViewControllerModeDefault];
}

- (UIViewController *)issuesViewControllerWithMode:(enum JMCViewControllerMode)mode {
    if (mode == JMCViewControllerModeCustom) {
        return [self _issuesController]; 
    }
    else {
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:[self _issuesController]] autorelease];
        navigationController.navigationBar.barStyle =  self.options.barStyle;
        navigationController.modalPresentationStyle = self.options.modalPresentationStyle;
        return navigationController;
    }
}

-(UIImage*) feedbackIcon {
    return [UIImage imageNamed:@"megaphone.png"];
}

- (NSDictionary *)getMetaData
{
    UIDevice *device = [UIDevice currentDevice];
    NSDictionary *appMetaData = [[NSBundle mainBundle] infoDictionary];
    NSMutableDictionary *info = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    
    // add device data
    [info setObject:[self getUUID] forKey:@"uuid"];
    [info setObject:[device name] forKey:@"devName"];
    [info setObject:[device systemName] forKey:@"systemName"];
    [info setObject:[device systemVersion] forKey:@"systemVersion"];
    [info setObject:[device model] forKey:@"model"];

    NSLocale *locale = [NSLocale currentLocale];
    NSString *language = [locale displayNameForKey:NSLocaleLanguageCode
                                             value:[locale localeIdentifier]]; 

    if (language) [info setObject:language forKey:@"language"];
    
    // app application data
    NSString* bundleVersion = [appMetaData objectForKey:@"CFBundleVersion"];
    NSString* bundleVersionShort = [appMetaData objectForKey:@"CFBundleShortVersionString"];
    NSString* bundleName = [appMetaData objectForKey:@"CFBundleName"];
    NSString* bundleDisplayName = [appMetaData objectForKey:@"CFBundleDisplayName"];
    NSString* bundleId = [appMetaData objectForKey:@"CFBundleIdentifier"];
    if (bundleVersion) [info setObject:bundleVersion forKey:@"appVersion"];
    if (bundleVersionShort) [info setObject:bundleVersionShort forKey:@"appVersionShort"];
    if (bundleName) [info setObject:bundleName forKey:@"appName"];
    if (bundleDisplayName) [info setObject:bundleName forKey:@"appDisplayName"];
    if (bundleId) [info setObject:bundleId forKey:@"appId"];
    
    return info;
}

- (NSString *)getAppName
{
    NSDictionary *metaData = [self getMetaData];
    if ([metaData objectForKey:@"appName"])        return [metaData objectForKey:@"appName"];
    if ([metaData objectForKey:@"appDisplayName"]) return [metaData objectForKey:@"appDisplayName"];
    return @"this App";
}

- (NSString *)getUUID
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kJIRAConnectUUID];
}

- (NSString *) getAPIVersion
{
    return @"1.0"; // TODO: pull this from a map. make it a config, etc..
}

- (NSString *)getProject
{
    if ([_customDataSource respondsToSelector:@selector(project)]) {
        return [_customDataSource project]; // for backward compatibility with the beta... deprecated
    }
    if (self.options.projectKey != nil) {
        return self.options.projectKey;
    }
    return [self getAppName];
}


-(NSMutableDictionary *)getCustomFields
{
    NSMutableDictionary *customFields = [[[NSMutableDictionary alloc] init] autorelease];
    if ([_customDataSource respondsToSelector:@selector(customFields)]) {
        [customFields addEntriesFromDictionary:[_customDataSource customFields]];
    }
    if (_options.customFields) {
        [customFields addEntriesFromDictionary:_options.customFields];
    }
    return customFields;
}

-(NSArray *)components
{
    if ([_customDataSource respondsToSelector:@selector(components)]) {
        return [_customDataSource components];
    }
    return [NSArray arrayWithObject:@"iOS"];
}

-(NSString *)getApiKey
{
    return _options.apiKey ? _options.apiKey : @"";
}

- (BOOL)isPhotosEnabled {
    return _options.photosEnabled;
}

- (BOOL)isLocationEnabled {
    return _options.locationEnabled;
}

- (BOOL)isVoiceEnabled {
    return _options.voiceEnabled && [JMCRecorder audioRecordingIsAvailable]; // only enabled if device supports audio input
}

-(NSString*) issueTypeNameFor:(JMCIssueType)type useDefault:(NSString *)defaultType {
    if (([_customDataSource respondsToSelector:@selector(jiraIssueTypeNameFor:)])) {
        NSString * typeName = [_customDataSource jiraIssueTypeNameFor:type];
        if (typeName != nil) {
            return typeName;
        }
    }
    return defaultType;
}

-(UIBarStyle) getBarStyle {
    return _options.barStyle;
}


-(CGRect)notifierStartFrame
{
    if ([_customDataSource respondsToSelector:@selector(notifierStartFrame)]) {
        return [_customDataSource notifierStartFrame];
    }
    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
    return CGRectMake(0, screenSize.height + 40, screenSize.width, 40);
}

-(CGRect)notifierEndFrame
{
    if ([_customDataSource respondsToSelector:@selector(notifierEndFrame)]) {
        return [_customDataSource notifierEndFrame];
    }
    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
    return CGRectMake(0, screenSize.height - 20, screenSize.width, 40);
}

- (NSString *)dataDirPath 
{
    return self._dataDirPath;
}

// copied from http://developer.apple.com/library/ios/#qa/qa1719/_index.html
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

- (NSString *)makeDataDirPath 
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *cache = [paths objectAtIndex:0];
    NSString *dataDirPath = [cache stringByAppendingPathComponent:@"JMC"];
    
    if (![fileManager fileExistsAtPath:dataDirPath]) {
        [fileManager createDirectoryAtPath:dataDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:dataDirPath]];
    return dataDirPath;
}


@end

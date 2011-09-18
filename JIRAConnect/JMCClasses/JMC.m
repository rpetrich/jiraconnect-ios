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
#import "Core/JMCPing.h"
#import "Core/JMCNotifier.h"
#import "Core/JMCCrashSender.h"

@interface JMC ()

@property (nonatomic, retain) JMCPing * _pinger;
@property (nonatomic, retain) JMCNotifier * _notifier;
@property (nonatomic, retain) JMCViewController * _jcController;
@property (nonatomic, retain) UINavigationController* _navController;
@property (nonatomic, retain) JMCCrashSender *_crashSender;
@property (nonatomic, assign) id <JMCCustomDataSource> _customDataSource;

@end


@implementation JMC

@synthesize url = _url;
@synthesize _pinger;
@synthesize _notifier;
@synthesize _jcController;
@synthesize _navController;
@synthesize _crashSender;
@synthesize _customDataSource;

+ (JMC *)instance
{
    static JMC *singleton = nil;
    
    if (singleton == nil) {
        singleton = [[JMC alloc] init];
    }
    return singleton;
}

- (id)init
{
    if ((self = [super init])) {
        self._pinger = [[[JMCPing alloc] init] autorelease ];
        self._crashSender = [[[JMCCrashSender alloc] init] autorelease ];
        self._jcController = [[[JMCViewController alloc] initWithNibName:@"JMCViewController" bundle:nil] autorelease ];
        self._navController = [[[UINavigationController alloc] initWithRootViewController:_jcController] autorelease ];
        _navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    return self;
}

- (void)dealloc
{
    self.url = nil;
    [_pinger release];
    [_notifier release];
    [_jcController release];
    [_navController release];
    [_crashSender release];
    [super dealloc];
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

- (void)configureJiraConnect:(NSString *)withUrl customDataSource:(id <JMCCustomDataSource>)customDataSource
{
    [CrashReporter enableCrashReporter];
    
    self.url = [NSURL URLWithString:withUrl];
    [self generateAndStoreUUID];

    _pinger.baseUrl = self.url;

    _customDataSource = customDataSource;
    _jcController.payloadDataSource = _customDataSource;

    JMCIssuesViewController *issuesController = [[JMCIssuesViewController alloc] initWithStyle:UITableViewStylePlain];
    JMCNotifier* notifier = [[JMCNotifier alloc] initWithIssuesViewController:issuesController];
    self._notifier = notifier;
    [issuesController release];
    [notifier release];

    // TODO: firing this when network becomes active would be better
    [NSTimer scheduledTimerWithTimeInterval:3 target:_crashSender selector:@selector(promptThenMaybeSendCrashReports) userInfo:nil repeats:NO];
    // whenever the Application Becomes Active, ping for notifications from JIRA.
    [[NSNotificationCenter defaultCenter] addObserver:_pinger selector:@selector(start) name:UIApplicationDidBecomeActiveNotification object:nil];
    NSLog(@"JiraConnect is Configured with url: %@", withUrl);

}

- (UIViewController *)viewController
{
    return _navController;
}

- (UIViewController *)issuesViewController
{
    [_notifier populateIssuesViewController];
    return _notifier.viewController;
}

- (NSDictionary *)getMetaData
{
    UIDevice *device = [UIDevice currentDevice];
    NSDictionary *appMetaData = [[NSBundle mainBundle] infoDictionary];
    NSMutableDictionary *info = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    
    // add device data
    [info setObject:[device uniqueIdentifier] forKey:@"udid"];
    [info setObject:[self getUUID] forKey:@"uuid"];
    [info setObject:[device name] forKey:@"devName"];
    [info setObject:[device systemName] forKey:@"systemName"];
    [info setObject:[device systemVersion] forKey:@"systemVersion"];
    [info setObject:[device model] forKey:@"model"];
    
    
    // app application data 
    [info setObject:[appMetaData objectForKey:@"CFBundleVersion"] forKey:@"appVersion"];
    [info setObject:[appMetaData objectForKey:@"CFBundleName"] forKey:@"appName"];
    [info setObject:[appMetaData objectForKey:@"CFBundleIdentifier"] forKey:@"appId"];
    
    return info;
}

- (NSString *)getAppName
{
    return [[self getMetaData] objectForKey:@"appName"];
}

- (NSString *)getUUID
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kJIRAConnectUUID];
}

- (NSString *)getProject
{
    if ([_customDataSource respondsToSelector:@selector(project)]) {
        return [_customDataSource project];
    }
    return [self getAppName];
}

- (BOOL)isPhotosEnabled {
    return ([_customDataSource respondsToSelector:@selector(photosEnabled)]) ?
    ([_customDataSource photosEnabled]) : YES; // defaults to YES
}


- (BOOL)isVoiceEnabled {
    BOOL voiceEnabled = ([_customDataSource respondsToSelector:@selector(voiceEnabled)]) ?
    ([_customDataSource voiceEnabled]) : YES; // defaults to YES
    return voiceEnabled && [JMCRecorder audioRecordingIsAvailable]; // only enabled if device supports audio input
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

@end

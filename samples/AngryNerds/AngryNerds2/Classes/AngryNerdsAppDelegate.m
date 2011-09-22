#import "AngryNerdsAppDelegate.h"
#import "JMC.h"

@implementation AngryNerdsAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /*
     To configure JIRA Mobile Connect:
     1. call [[JMC instance] configureJiraConnect:@"url to your JIRA instance" customDataSource:<AnyCustomDataSource>];
     2. You can then present [JMC instance].viewController from anywhere in your app
     3. Be sure that your JIRA instance has the JIRA Mobile Connect plugin installed. (https://plugins.atlassian.com/plugin/details/322837)
     4. Ensure your JIRA instance has a project with the same name as either:
     *    * your Application Bundle Name
     *    * the same value as returned by your [JMCCustomDataSource projectName]
     */
//    [[JMC instance] configureJiraConnect:@"http://connect.onjira.com" customDataSource:viewController];
//    [[JMC instance] configureJiraConnect:@"http://localhost:2990/jira/" customDataSource:viewController];

//    [[JMC instance] configureJiraConnect:@"http://localhost:2990/jira/" customDataSource:viewController];
    
    [[JMC instance] configureJiraConnect:@"http://localhost:2990/jira/"
                              projectKey:@"FOUR"
                                  apiKey:@"e98c9722-2fa8-4198-adbe-0b1a21f837a2"];
    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your 
     application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end

JIRA Mobile Connect for iOS
===========================

JIRAConnect is an iOS library that can be embedded into any iOS App to provide following extra functionality:

* **Real Time Crash Reporting** have users or testers submit crash reports directly to your JIRA instance
* **User or Tester Feedback** views for allowing users or testers to create a bug report within your app.
* **Rich Data Input** users can attach and annotate screenshots, leave a voice message, have their location sent
* **2-way Communication with Users** thank your users or testers for providing feedback on your App!

![Report Issue Screen](https://bytebucket.org/atlassian/jiraconnect-ios/wiki/small_report-issue.png) ![Crash Report Dialog](https://bytebucket.org/atlassian/jiraconnect-ios/wiki/small_crash-report.png) ![2-Way Communications](https://bytebucket.org/atlassian/jiraconnect-ios/wiki/small_replies-view.png)


Getting Started
===============

To install JIRA Mobile Connect into your current project:
-------------------------------------------------

1. `hg clone ssh://hg@bitbucket.org/atlassian/jiraconnect-ios` or download the
   latest release:
   [https://bitbucket.org/atlassian/jiraconnect-ios/get/tip.zip](https://bitbucket.org/atlassian/jiraconnect-ios/get/tip.zip)
1. Open your project in Xcode (Xcode 4 is used for the purposes), right click on your Classes group, and select **'Add Files to YourProjectName'**
1. Browse to the **jiraconnect-ios** clone directory, and add the entire JIRAConnect/JMCClasses directory to your project.
1. If the project you are integrating already contains the Reachability or PLCrashReporter libraries, remove those from the JMCClasses/Libraries directory.
1. If your project does *not* contain a JSON parsing library, then add the SBJSON library from Support/SBJSON to your project.
1. Open the project (top most) element in the file/groups tree
1. Click **'Build Phases'** --> Expand **'Link Binary with Libraries'** --> **+**
1. Add the iOS built-in frameworks:
    * CFNetwork
    * SystemConfiguration
    * MobileCoreServices
    * CoreGraphics
    * AVFoundation
    * CoreLocation
    * libsqlite3 (used to cache issues on the device)
1. If you use automatic reference counting (ARC) you will need to disable it for the JIRA Mobile Connect code:
    * In the **'Build Phases'** view, expand **'Compile Sources'**
    * For all JMC source files, set `-fno-objc-arc` as the compiler flags
1. Build your App, and ensure there are no errors.

To use JIRAConnect in your App:
-------------------------------
1. Import the JMC.h header file into your ApplicationDelegate

        #import "JMC.h"

1. Configure the [JMC sharedInstance] in your ApplicationDelegate.m like so:


    `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`
method, add the following line:

        [[JMC sharedInstance] configureJiraConnect:@"https://connect.onjira.com/"
                                  projectKey:@"NERDS"
                                      apiKey:@"591451a6-bc59-4ca9-8840-b67f8c1e440f"];

1. Replace the string @"https://connect.onjira.com" with the location of the JIRA instance you wish to connect to. NB: We highly recommend you use https (not http) to ensure secure communication between JMC and the User.
    * Replace the string @"NERDS" with the name of the project you wish to use for collecting feedback from users or testers
    * If the JIRA Mobile Connect plugin in JIRA has an API Key enabled, update the above apiKey parameter with the key for your project

1. The JIRA instance at the URL you configured above, will need to have:
    * the [JIRA Mobile Connect Plugin](https://plugins.atlassian.com/plugin/details/322837) installed
    * JIRA Mobile Connect enabled for your project. 'Administer Project' --> *Your Project* --> Settings --> JIRA Mobile Connect
![Administration --> *Your Project* --> Settings --> JIRA Mobile Connect](https://bytebucket.org/atlassian/jiraconnect-ios/wiki/jira_settings.png)

1. Provide a trigger mechanism to allow users invoke the Feedback view. This typically goes on the 'About' or 'Info' view.
(Or, if you are feeling creative: add it to the Shake Gesture as is done in the sample Angry Nerds App!)
The UIViewController returned by JMC viewController is designed to be presented modally.
If your info ViewController is in a UINavigationController stack, then you can use the following snippet to show both the feedback view, and the history view.

        #import "JMC.h"

        - (void)viewDidLoad
        {
            self.navigationItem.rightBarButtonItem =
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                           target:self
                                                           action:@selector(showFeedback)] autorelease];
        }

        -(void) showFeedback
        {
            [self presentModalViewController:[[JMC sharedInstance] viewController] animated:YES];
        }

1. [[JMC sharedInstance] viewController] will return the 'Create Issue' view until the user creates feedback. From then on, the 'Issue Inbox' view is displayed, from where the
user can tap the 'Create' icon to send more feedback.
1. If you would like your users to always access the Create Issue view, then you can do so by presenting the [[JMC sharedInstance] feedbackViewController] directly.
e.g. the following will present just the create issue ViewController programatically:

        - (IBAction)triggerCreateIssueView
        {
            [self presentModalViewController:[[JMC sharedInstance] feedbackViewController] animated:YES];
        }
Use [[JMC sharedInstance] issuesViewController] to simply present the inbox directly.

1. You can test the Crash Reporting, simply by adding a CFRelease(NULL); statement somewhere in your code. 

Advanced Configuration Options
------------------------------

There are some other configuration options you can choose to set, if the defaults aren't what you require. To do this, explore the [JMC sharedInstance] configureXXX] methods.
The JMCOptions object supports most of the advanced settings. This object gets passed to JMC when configure is called. ie during applicationDidFinishLaunching. The JMCOptions class lets you configure:

  * screenshots
  * voice recordings
  * location tracking
  * crash reporting
  * custom fields
  * UIBarStyle for JMC Views
  * JIRA Project Key
  * JIRA instance URL
  * API Key

See the the JMC.h file for all JMCOptions available.

The JMCCustomDataSource can be used to provide JIRA with extra data at runtime. The following is supported:

  * an extra attachment (e.g. a database file)
  * customFields (these get mapped by key name if a custom field of the same name exists for the JIRA project)
  * issue components to set (e.g. iOS)
  * JIRA issue type - maps the name of the issue-type to use in JIRA. e.g. a Crash --> Bug, Feedback --> Improvement.
  * notifierStartFrame, notifierEndFrame: used to control where the notifier is animated from and to.

See the JMCCustomDataSource.h file for more information on these settings.

Integration Notes
-----------------

* The notification view that slides up when a notification is received, is added to the application's keyWindow.

Sample Apps
-----------
There are sample iPhone and iPad Apps in the jiraconnect-ios/samples directory.
AngryNerds and AngryNerds4iPad both demonstrate submitting feedback and crashes to the
[NERDS](https://connect.onjira.com/browse/NERDS) public project.

JIRA Plugin
===========
You will need access to a JIRA instance with the [JIRA Mobile Connect Plugin](https://plugins.atlassian.com/plugin/details/322837) installed.

If you don't yet have access to a JIRA instance, you can use the NERDS project at http://connect.onjira.com for testing.


Issue tracking
==============

Use [http://connect.onjira.com/browse/CONNECT](http://connect.onjira.com/browse/CONNECT) to raise any issue with the JIRA Mobile Connect library.

Need Help?
=========

If you have any questions regarding JIRA Mobile Connect, please ask on [Atlassian Answers](https://answers.atlassian.com/tags/jira-mobile-connect/).

Contributors
============
* Nick Pellow [@niick](http://twitter.com/niick)
* Thomas Dohmke [@ashtom](http://twitter.com/ashtom)
* Stefan Saasen [@stefansaasen](http://twitter.com/stefansaasen)
* Shihab Hamid [@shihabhamid](http://twitter.com/shihabhamid)
* Erik Romijn [@erikpub](http://twitter.com/erikpub)
* Bindu Wavell [@binduwavell](http://twitter.com/binduwavell)

Third party Package - License - Copyright / Creator
===================================================

plcrashreporter     MIT     Copyright (c) 2008-2009 [Plausible Labs Cooperative, Inc.]( http://code.google.com/p/plcrashreporter/)

crash-reporter              Copyright (c) 2009 Andreas Linde & Kent Sutherland.

UIImageCategories           Created by [Trevor Harmon.](http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/)

FMDB                MIT     Copyright (c) 2008 [Flying Meat Inc.](http://github.com/ccgus/fmdb)


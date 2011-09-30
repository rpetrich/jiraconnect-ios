JIRA Mobile Connect for iOS (beta)
===========================

JIRAConnect is an iOS library that can be embedded into any iOS App to provide following extra functionality:

* **Real Time Crash Reporting** have users or testers submit crash reports directly to your JIRA instance
* **User or Tester Feedback** views for allowing users or testers to create a bug report within your app.
* **2-way Communication with Users** thank your users or testers for providing feedback on your App!

![Report Issue Screen](https://bytebucket.org/atlassian/jiraconnect-ios/wiki/small_report-issue.png) ![Crash Report Dialog](https://bytebucket.org/atlassian/jiraconnect-ios/wiki/small_crash-report.png) ![2-Way Communications](https://bytebucket.org/atlassian/jiraconnect-ios/wiki/small_replies-view.png)


Getting Started
===============

To install JIRA Mobile Connect into your current project:
-------------------------------------------------

1. `hg clone ssh://hg@bitbucket.org/atlassian/jiraconnect-ios` or download the
   latest release:
   [https://bitbucket.org/atlassian/jiraconnect-ios/get/tip.zip](https://bitbucket.org/atlassian/jiraconnect-ios/get/tip.zip)
1. Open your project in XCode, right click on your Classes group, and select **'Add Files to YourProjectName'**
1. Browse to the **jiraconnect-ios** clone directory, and add the entire JIRAConnect/JMCClasses directory to your project.
1. If the project you are integrating contains any of the 3rd Party libaries listed at the bottom of this page, you shouldn't need to copy the equivalent library in JIRAConnect/JMCClasses/Libraries.
1. Open the project (top most) element in the file/groups tree
1. Click **'Build Phases'** --> Expand **'Link Binary with Libraries'** --> **+**
1. Add the iOS built-in frameworks:
    * CFNetwork
    * SystemConfiguration
    * MobileCoreServices
    * CoreGraphics
    * AVFoundation
    * CoreLocation
    * libz
    * libsqlite3
1. Add the `CrashReporter.framework`:
    * Click **+** --> **'Add Other'**
    * Browse to jiraconnect-ios then **JIRAConnect/JMCClasses/Libraries/** --> **CrashReporter.framework**
    * Click **'Open'**
1. If you use automatic reference counting (ARC) you will need to disable it for the JIRA Mobile Connect code:
    * In the **'Build Phases'** view, expand **'Compile Sources'**
    * For all JMC source files, set `-fno-objc-arc` as the compiler flags
1. Try compiling your App, and ensure there are no errors.

To use JIRAConnect in your App:
-------------------------------
1. Import the JMC.h header file into your ApplicationDelegate

        #import "JMC.h"

1. Configure the [JMC instance] at the *end* of the ApplicationDelegate.m like so:


    `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`
method, add the following line:

        [[JMC instance] configureJiraConnect:@"http://connect.onjira.com/"
                                  projectKey:@"NERDS"
                                      apiKey:@"591451a6-bc59-4ca9-8840-b67f8c1e440f"];

1. Replace the string @"http://connect.onjira.com" with the location of the JIRA instance you wish to connect to.
    * Replace the string @"NERDS" with the name of the project you wish to use for collecting feedback from users or testers
    * If the JIRA Mobile Connect plugin in JIRA has an API Key enabled, update the above apiKey parameter with the key for your project

1. The JIRA URL you configured above, will need to have:
    * the jconnect-plugin installed
    * the project mentioned above has JIRA Mobile Connect enabled.

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
            [self presentModalViewController:[[JMC instance] viewController] animated:YES];
        }

1. [[JMC instance] viewController] will return the 'Create Issue' view until the user creates feedback. From then on, the 'Issue Inbox' view is displayed, from where the
user can tap the 'Create' icon to send more feedback.
1. If you would like your users to always access the Create Issue view, then you can do so by presenting the [[JMC instance] feedbackViewController] directly.

e.g. the following will present the issue inbox programatically:

        - (IBAction)triggerCreateIssueView
        {
            [self presentModalViewController:[[JMC instance] feedbackViewController] animated:YES];
        }

Integration Notes
-----------------

* The notification view that slides up when a notification is received, is added to the application's keyWindow.

JIRA Plugin
===========
You will need access to a JIRA instance with the [JIRA Mobile Connect Plugin](https://plugins.atlassian.com/plugin/details/322837) installed.

Alternatively, for a limited time, you can use the NERDS project at http://connect.onjira.com .


Issue tracking
==============

Use [http://connect.onjira.com/browse/CONNECT](http://connect.onjira.com/browse/CONNECT) to raise any issue with the JIRA Mobile Connect library for testing.


Third party Package - License - Copyright / Creator
===================================================

asi-http-request    BSD     Copyright &copy; 2007-2011, [All-Seeing Interactive](http://allseeing-i.com/ASIHTTPRequest/)

json-framework      BSD     Copyright &copy; 2009 [Stig Brautaset.]( http://code.google.com/p/json-framework/)

plcrashreporter     MIT     Copyright (c) 2008-2009 [Plausible Labs Cooperative, Inc.]( http://code.google.com/p/plcrashreporter/)

crash-reporter              Copyright &copy; 2009 Andreas Linde & Kent Sutherland.

UIImageCategories           Created by [Trevor Harmon.](http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/)

FMDB                MIT     Copyright &copy; 2008 [Flying Meat Inc.](http://github.com/ccgus/fmdb)


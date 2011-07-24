JIRA Mobile Connect for iOS (alpha)
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
1. Browse to the **jiraconnect-ios** clone directory, and add the entire JIRAConnect/JCOClasses directory to your project.
1. If the project you are integrating contains any of the 3rd Party libaries listed at the bottom of this page, you shouldn't need to copy the equivalent library in JIRAConnect/JCOClasses/Libraries.
1. Select the project (top most) element in the file/groups tree
1. Click **'Build Phases'** --> Expand **'Link Binary with Libraries'** --> **+**
1. add the following frameworks:
    * CFNetwork
    * SystemConfiguration
    * MobileCoreServices
    * CoreGraphics
    * AVFoundation
    * CoreLocation
    * libz1.2.3
    * libsqlite3
1. Add the `CrashReporter.framework` to your project's frameworks: **+** --> **'Add Other'**
1. Browse to jiraconnect-ios then **JIRAConnect/JCOClasses/Libraries/** --> **CrashReporter.framework**
1. Click **'Open'**
1. Try compiling your App, and ensure there are no errors.

To use JIRAConnect in your App:
-------------------------------
1. Import the JCO.h header file into your ApplicationDelegate

        #import "JCO.h"

1. Configure the [JCO instance] at the *end* of the ApplicationDelegate.m like so:


    `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`
method, add the following line:

        [[JCO instance] configureJiraConnect:@"http://connect.onjira.com" customDataSource:nil];

1. Replace the string @"http://connect.onjira.com" with the location of the JIRA instance you wish to connect to.

1. The JIRA URL you configured above, will need to have:
    * the jconnect-plugin installed
    * a project named either the same as
        * the XCode Project,
        * or the value returned by your [id&lt;JCOCustomDataSource&gt; project] method. This can be the project key in JIRA, or the project's name.

1. Provide a trigger mechanism to allow users invoke the Submit Feedback view. This typically goes on the 'About' or 'Info' view.
The UIViewController returned by JCO viewController is designed to be presented modally.
If your info ViewController is in a UINavigationController stack, then you can use the following snippet to show both the feedback view, and the history view.


        #import "JCO.h"

        - (void)viewDidLoad
        {
            self.navigationItem.rightBarButtonItem =
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                           target:self
                                                           action:@selector(showFeedback)] autorelease];
            self.navigationItem.leftBarButtonItem =
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                           target:self
                                                           action:@selector(showPastFeedback)] autorelease];
        }

        -(void) showFeedback
        {
            [self presentModalViewController:[[JCO instance] viewController] animated:YES];
        }

        -(void) showPastFeedback
        {
            [self presentModalViewController:[[JCO instance] issuesViewController] animated:YES];
        }

1. If you would like your users to access their issue 'inbox' anytime, then you can do so by presenting the JCOIssuesViewController.

e.g. the following will present the issue inbox programatically:

        - (IBAction)triggerDisplayNotifications
        {
            [self presentModalViewController:[[JCO instance] issuesViewController] animated:YES];
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

asi-http-request	BSD		Copyright &copy; 2007-2011, [All-Seeing Interactive](http://allseeing-i.com/ASIHTTPRequest/)

json-framework      BSD     Copyright &copy; 2009 [Stig Brautaset.]( http://code.google.com/p/json-framework/)

plcrashreporter     MIT     Copyright (c) 2008-2009 [Plausible Labs Cooperative, Inc.]( http://code.google.com/p/plcrashreporter/)

crash-reporter              Copyright &copy; 2009 Andreas Linde & Kent Sutherland.

UIImageCategories           Created by [Trevor Harmon.](http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/)

FMDB                MIT     Copyright &copy; 2008 [Flying Meat Inc.](http://github.com/ccgus/fmdb)


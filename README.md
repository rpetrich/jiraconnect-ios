JIRAConnect for iOS
===================

JIRAConnect is an iOS library that can be embedded into any iOS App to provide following extra functionality:

        * **Real Time Crash Reporting** have users or testers submit crash reports directly to your JIRA instance
        * **User or Tester Feedback** views for allowing users or testers to create a bug report within your app.
        * **2-way Communication with Users** thank your users or testers for providing feedback on your App!

Getting Started
===============

To install JIRAConnect into your current project:
-------------------------------------------------

1. git clone git@github.com:atlassian/jiraconnect-ios.git
1. Open your project in XCode, right click on your Classes group, and select 'Add Files to YourProjectName'
1. Browse to the jiraconnect-ios directory, and add the entire JCOClasses directory to your project.
1. Select the project (top most) element in the file/groups tree
1. Click 'Build Phases' --> Expand 'Link Binary with Libraries' --> +
1. add the following frameworks:
    * CFNetwork,
    * SystemConfiguration,
    * MobileCoreServices,
    * CoreGraphics,
    * AVFoundation,
    * CoreLocation
    * libz1.2.3

1. Add the Resources/CrashReporter.framework to your project's frameworks: + --> 'Add Other'
1. Browse to jiraconnect-ios then Resources --> CrashReporter.framework
1. Click 'Open'

To use JIRAConnect in your App:
-------------------------------
1. In your App's AppDelegate.m, at the *end* of the

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    method, add the following line:

    [[JCO instance] configureJiraConnect:@"http://connect.onjira.com" customData:nil];

    Replace the string @"http://connect.onjira.com" with the location of the JIRA instance you wish to connect to.
    You will also need to add
        #import "JCO.h"
    at the top of this file.
1. The JIRA you configured above, will need to have:
  * the jconnect-plugin installed
  * a project named either the same as
    ** the XCode Project,
    ** the value returned by your [id<JCOCustomDataSource> project] method. This can be the project key in JIRA, or the project's name.
  

1. Provide a trigger mechanism to allow users invoke the Submit Feedback view:
This will often go on an 'About' or 'Info' view. The UIViewController returned by JCO viewController is designed to be presented modally.
If your ViewController is in a UINavigationController stack, then you can use the following snippet to show both the
feedback view, and the history view.

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

Third party Package - License - Copyright / Creator
===================================================

asi-http-request	BSD		Copyright &copy; 2007-2011, All-Seeing Interactive http://allseeing-i.com/ASIHTTPRequest/
json-framework      BSD     Copyright &copy; 2009 Stig Brautaset. http://code.google.com/p/json-framework/
plcrashreporter     MIT     Copyright (c) 2008-2009 Plausible Labs Cooperative, Inc. http://code.google.com/p/plcrashreporter/
crash-reporter              Copyright &copy; 2009 Andreas Linde & Kent Sutherland. 
UIImageCategories           Created by Trevor Harmon on 9/20/09. http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/


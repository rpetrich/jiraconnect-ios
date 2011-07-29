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
#import "JMCNotifier.h"
#import "JMCIssueStore.h"
#import "../JMC.h"

@implementation JMCNotifier

UIToolbar *_toolbar;
UILabel *_label;
UIButton *_button;

- (id)initWithView:(UIView *)parentView {
    if ((self = [super init])) {

        self.view = parentView;

        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 520, 320, 40)];
        [_toolbar setBarStyle:UIBarStyleBlack];
        [_toolbar setTranslucent:YES];

        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 20)];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = UITextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        [_toolbar addSubview:_label];

        _button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [_button setFrame:CGRectMake(0, 440, 320, 40)];
        [_button addTarget:self action:@selector(displayNotifications:) forControlEvents:UIControlEventTouchUpInside];

        self.issuesViewController = [[[JMCIssuesViewController alloc] initWithNibName:@"JMCIssuesViewController" bundle:nil] autorelease];

        _viewController = [[UINavigationController alloc] initWithRootViewController:self.issuesViewController];
        _viewController.navigationBar.barStyle = UIBarStyleBlack;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify:) name:kJCOReceivedCommentsNotification object:nil];

    }
    return self;
}

- (void)populateIssuesViewController {
    [self.issuesViewController loadView];
    [self.issuesViewController setIssueStore:[JMCIssueStore instance]];
}

- (void)notify:(NSTimer *)timer {
    // check notifications
    if ([JMCIssueStore instance].newIssueCount > 0) {
//	if ([JCOIssueStore instance].issues) {

        int count = [JMCIssueStore instance].newIssueCount;
        NSString *pluralSuffix = count != 1 ? @"s" : @"";
        _label.text = [NSString stringWithFormat:@"%d new notification%@ from developer", count, pluralSuffix];

        [self populateIssuesViewController];

        [_toolbar setFrame:CGRectMake(0, 520, 320, 40)];
        [_view addSubview:_toolbar];

        [UIView beginAnimations:@"animateToolbar" context:nil];
        [UIView setAnimationDuration:0.4];
        [_toolbar setFrame:CGRectMake(0, 440, 320, 40)]; //notice this is ON screen!
        [UIView commitAnimations];

        [_view addSubview:_button];
    } else {
        // nothing to display...
    }
}

- (void)displayNotifications:(id)sender {
    [self.viewController.view setFrame:CGRectMake(0, 480, 320, 480)];
    [self.view addSubview:self.viewController.view];

    [UIView beginAnimations:@"animateView" context:nil];
    [UIView setAnimationDuration:0.4];
    [self.viewController.view setFrame:CGRectMake(0, 0, 320, 480)]; //notice this is ON screen!
    [UIView commitAnimations];

    [_button removeFromSuperview];
    [_toolbar removeFromSuperview];
}

@synthesize viewController = _viewController, view = _view, issuesViewController = _issuesViewController;

- (void)dealloc {

    self.view = nil, self.viewController = nil, self.issuesViewController = nil;
    [_label release];
    _label = nil;
    [_toolbar release];
    _toolbar = nil;
    [_button release];
    _button = nil;
    [super dealloc];
}

@end

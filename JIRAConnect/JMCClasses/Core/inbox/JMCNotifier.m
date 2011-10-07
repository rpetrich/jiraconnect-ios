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
#import "JMC.h"

@implementation JMCNotifier

UIToolbar *_toolbar;
UILabel *_label;
UIButton *_button;
CGRect startFrame;
CGRect endFrame;

- (id)initWithStartFrame:(CGRect)start endFrame:(CGRect)end {
    if ((self = [super init])) {
        self.issuesViewController = [[[JMCIssuesViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        self.issuesViewController.isModal = NO;

        startFrame = start;
        endFrame = end;
        
        _toolbar = [[UIToolbar alloc] initWithFrame:startFrame];
        [_toolbar setBarStyle:UIBarStyleBlack];
        [_toolbar setTranslucent:YES];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 20)];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = UITextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        [_toolbar addSubview:_label];

        _button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [_button setFrame:endFrame];
        [_button addTarget:self action:@selector(displayNotifications:) forControlEvents:UIControlEventTouchUpInside];

        _viewController = [[UINavigationController alloc] initWithRootViewController:self.issuesViewController];
        _viewController.navigationBar.barStyle = [[JMC instance] getBarStyle];
        

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify:) name:kJMCReceivedCommentsNotification object:nil];

    }
    return self;
}

- (void)populateIssuesViewController {
    [self.issuesViewController loadView];
    [self.issuesViewController setIssueStore:[JMCIssueStore instance]];
}

- (void)notify:(NSTimer *)timer {
    // check notifications
    if (!_view) {
        _view =  [[UIApplication sharedApplication] keyWindow];
    }
    if ([JMCIssueStore instance].newIssueCount > 0) {

        if (!_view) {
            // since there is no nice way to detect whether or not keyWindow has been setup,
            // try and display notification 4 times, before giving up. This means JMC can be configured
            // immediately on app launch.
            NSNumber* repeatCount = timer.userInfo ? timer.userInfo : [NSNumber numberWithInt:3];
            if (repeatCount.intValue <= 0) {
                NSLog(@"In-App notification for replies can not be displayed since keyWindow was never intialised.");
                return;
            }
            [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(notify:) userInfo:[NSNumber numberWithInt:repeatCount.intValue - 1] repeats:NO];
        }
        int count = [JMCIssueStore instance].newIssueCount;
        NSString *pluralSuffix = count != 1 ? @"s" : @"";
        _label.text = [NSString stringWithFormat:@"%d new notification%@ from developer", count, pluralSuffix];

        [self populateIssuesViewController];

        [_toolbar setFrame:startFrame];
        [_view addSubview:_toolbar];

        [UIView beginAnimations:@"animateToolbar" context:nil];
        [UIView setAnimationDuration:0.4];
        [_toolbar setFrame:endFrame]; //notice this is ON screen!
        [UIView commitAnimations];

        [_view addSubview:_button];
    } else {
        // nothing to display...
    }
}

- (void)displayNotifications:(id)sender {
    
    CGRect currStartFrame = CGRectMake(startFrame.origin.x, startFrame.origin.y, 320, 480);
    CGRect currEndFrame = CGRectMake(0, 0, 320, 480);

    [self.viewController.view setFrame:currStartFrame];
    [self.view addSubview:self.viewController.view];

    [UIView beginAnimations:@"animateView" context:nil];
    [UIView setAnimationDuration:0.4];
    [self.viewController.view setFrame:currEndFrame]; //notice this is ON screen!
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

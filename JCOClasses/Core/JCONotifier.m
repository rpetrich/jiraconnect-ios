#import "JCONotifier.h"
#import "JCOIssueStore.h"
#import "JCO.h"

@implementation JCONotifier

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

        self.issuesViewController = [[[JCOIssuesViewController alloc] initWithNibName:@"JCOIssuesViewController" bundle:nil] autorelease];

        self.viewController = [[[UINavigationController alloc] initWithRootViewController:self.issuesViewController] autorelease];
        self.viewController.navigationBar.barStyle = UIBarStyleBlack;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify:) name:kJCOReceivedCommentsNotification object:nil];

    }
    return self;
}

- (void)populateIssuesViewController {
    [self.issuesViewController loadView];
    NSArray *data = [NSArray arrayWithObjects:[[JCOIssueStore instance] issues], nil];
    [self.issuesViewController setData:data];
}

- (void)notify:(NSTimer *)timer {
    // check notifications
    if ([JCOIssueStore instance].newIssueCount > 0) {
//	if ([JCOIssueStore instance].issues) {

        int count = [JCOIssueStore instance].newIssueCount;
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

    self.view, self.viewController, self.issuesViewController = nil;
    [_label release];
    _label = nil;
    [_toolbar release];
    _toolbar = nil;
    [_button release];
    _button = nil;
    [super dealloc];
}

@end

#import "AngryNerdsViewController.h"
#import "JMC.h"
#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation AngryNerdsViewController

@synthesize nerd = _nerd, nerdsView = _nerdsView, splashView = _splashView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hideSplash:) userInfo:nil repeats:NO];
    NSMutableArray *nerds = [NSMutableArray arrayWithObject:[UIImage imageNamed:@"frontend_blink"]];
    for (int i = 0; i < 20; i++) {
        [nerds addObject:[UIImage imageNamed:@"frontend"]];
    }

    [self.nerdsView setAnimationImages:nerds];
    [self.nerdsView setAnimationDuration:5];
    [self.nerdsView startAnimating];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


-(void) hideSplash:(NSTimer*) timer
{
    self.splashView.hidden = YES;
}

- (IBAction)triggerFeedback
{
    UIViewController *controller = [[JMC instance] viewController];

    [self presentModalViewController:controller animated:YES];
}

- (IBAction)triggerCrash
{
    NSLog(@"Triggering crash!");
    /* Trigger a crash. NB: if run from XCode, the sigquit handler wont be called to store crash data. */
#ifndef __clang_analyzer__
    CFRelease(NULL);
#endif
}

#pragma mark JCOCustomDataSource

- (NSDictionary *)customFields
{
    return [NSDictionary dictionaryWithObject:@"9999" forKey:@"Top Score"];
}

- (NSString *)jiraIssueTypeNameFor:(JMCIssueType)type
{
    if (type == JMCIssueTypeCrash) {
        return @"crash";
    } else if (type == JMCIssueTypeFeedback) {
        return @"improvement";
    }
    return nil;
}


- (JMCAttachmentItem *) attachment
{
    NSLog(@"Adding attachment...");
    return [[[JMCAttachmentItem alloc] initWithName:@"custom-attachment"
                                              data:[@"Add any other data as an attachment" dataUsingEncoding:NSUTF8StringEncoding]
                                              type:JMCAttachmentTypePayload
                                       contentType:@"text/plain"
                                    filenameFormat:@"customattachment.txt"] autorelease];
}


#pragma end

- (IBAction)triggerDisplayNotifications
{
    [self presentModalViewController:[[JMC instance] issuesViewController] animated:YES];
}

// allow shake gesture to trigger Feedback
- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self triggerFeedback];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{

}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{

}

- (void)jiggleNerd
{

    // Create the animation's path.
    CGPathRef path = NULL;
    CGMutablePathRef mutablepath = CGPathCreateMutable();
    CGPathMoveToPoint(mutablepath, NULL, self.nerdsView.center.x + 10, self.nerdsView.center.y);
    CGPathAddLineToPoint(mutablepath, NULL, self.nerdsView.center.x - 10, self.nerdsView.center.y);
    CGPathAddLineToPoint(mutablepath, NULL, self.nerdsView.center.x, self.nerdsView.center.y);
    CGPathAddLineToPoint(mutablepath, NULL, self.nerdsView.center.x + 10, self.nerdsView.center.y);
    CGPathAddArc(mutablepath, NULL, self.nerdsView.center.x, self.nerdsView.center.y, 5, 0, M_2_PI, YES);

    path = CGPathCreateCopy(mutablepath);
    CGPathRelease(mutablepath);
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.delegate = self;
    animation.path = path;
    animation.speed = 3.0;
    animation.repeatCount = 5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.delegate = self;
    [self.nerdsView.layer addAnimation:animation forKey:@"rotationAnimation"];
    CGPathRelease(path);
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [UIView animateWithDuration:0.7 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        NSLog(@"Crashing...");
#ifndef __clang_analyzer__
        CFRelease(NULL);
#endif
    }];
}

- (IBAction)bounceNerd
{

    UIViewAnimationOptions opts = UIViewAnimationOptionCurveEaseOut;
    [UIView animateWithDuration:0.2
                          delay:0 options:opts
                       animations:^{
                           self.nerdsView.top -= 100;
                       } completion:^(BOOL finished) {

        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.nerdsView.top += 100;
                         }
                         completion:^(BOOL fini) {
                             [self jiggleNerd];
                         }];
    }];

}

- (void)dealloc
{
    self.nerd = nil;
    self.nerdsView = nil;
    self.splashView = nil;
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


@end

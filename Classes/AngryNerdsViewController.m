#import "AngryNerdsViewController.h"
#import "JCO.h"
#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation AngryNerdsViewController

@synthesize nerd = _nerd, nerdsView = _nerdsView;
CLLocation *_currentLocation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[[CLLocationManager alloc] init] retain];
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
    NSMutableArray *nerds = [NSMutableArray arrayWithObject:[UIImage imageNamed:@"frontend_blink.png"]];
    for (int i = 0; i < 20; i++) {
        [nerds addObject:[UIImage imageNamed:@"frontend.png"]];
    }

    [self.nerdsView setAnimationImages:nerds];
    [self.nerdsView setAnimationDuration:5];
    [self.nerdsView startAnimating];
}

- (IBAction)triggerFeedback
{
    UIViewController *controller = [[JCO instance] viewController];
    [self presentModalViewController:controller animated:YES];
}

- (IBAction)triggerCrash
{
    NSLog(@"Triggering crash!");
    /* Trigger a crash. NB: if run from XCode, the sigquit handler wont be called to store crash data. */
    CFRelease(NULL);
}

#pragma mark JCOCustomDataSource

- (NSString *)project
{
    return @"AngryNerds";
}

- (NSDictionary *)customFields
{
    NSMutableArray *objects = [NSMutableArray arrayWithObjects:@"custom field value.", nil];
    NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"customer", nil];
    if (_currentLocation != nil) {
        @synchronized (self) {
            NSNumber *lat = [NSNumber numberWithDouble:_currentLocation.coordinate.latitude];
            NSNumber *lng = [NSNumber numberWithDouble:_currentLocation.coordinate.longitude];
            NSString *locationString = [NSString stringWithFormat:@"%f,%f", lat.doubleValue, lng.doubleValue];
            [keys addObject:@"lat"];      [objects addObject:lat];
            [keys addObject:@"lng"];      [objects addObject:lng];
            [keys addObject:@"location"]; [objects addObject:locationString];
        }
    }
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

- (NSDictionary *)payload
{
    return [NSDictionary dictionaryWithObject:@"store any custom information here." forKey:@"customer"];
}

#pragma end

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    @synchronized (self) {
        [_currentLocation release];
        _currentLocation = newLocation;
        [_currentLocation retain];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

}

- (IBAction)triggerDisplayNotifications
{
    [self presentModalViewController:[[JCO instance] issuesViewController] animated:YES];
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
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [UIView animateWithDuration:0.7 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        NSLog(@"Crashing...");
        CFRelease(NULL);
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
    self.nerd, self.nerdsView = nil;
    [_locationManager release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [_locationManager release];
    [super viewDidUnload];
}


@end

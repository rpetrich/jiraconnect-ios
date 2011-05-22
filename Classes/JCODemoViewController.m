
#import "JCODemoViewController.h"
#import "JCO.h"

@implementation JCODemoViewController

@synthesize triggerButtonCrash, triggerButtonFeedback, triggerButtonNotifications;
CLLocation *_currentLocation;

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
    NSLog(@"_locationManager: %@", _locationManager);
}

- (IBAction) triggerFeedback {
	UIViewController* controller = [[JCO instance] viewController];
	[self presentModalViewController:controller animated:YES];
}

- (IBAction) triggerCrash
{
	NSLog(@"Triggering crash!");
	/* Trigger a crash */
	CFRelease(NULL);
}

- (NSDictionary *)customFieldsFor:(NSString *)issueTitle {
    NSMutableArray *objects = [NSMutableArray arrayWithObjects:@"custom field value.", nil];
    NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"customer", nil];
    if (_currentLocation != nil) {
        @synchronized (self) {
            NSNumber *lat = [NSNumber numberWithDouble:_currentLocation.coordinate.latitude];
            NSNumber *lng = [NSNumber numberWithDouble:_currentLocation.coordinate.longitude];
            NSString *locationString = [NSString stringWithFormat:@"%f,%f", lat.doubleValue, lng.doubleValue];
            [keys addObject:@"lat"]; [objects addObject:lat];
            [keys addObject:@"lng"]; [objects addObject:lng];
            [keys addObject:@"location"]; [objects addObject:locationString];
        }
    }
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

- (NSDictionary *)payloadFor:(NSString *)issueTitle {
    return [NSDictionary dictionaryWithObject:@"store any custom information here." forKey:@"customer"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    @synchronized (self) {
        [_currentLocation release];
        _currentLocation = newLocation;
        [_currentLocation retain];
    }
}

- (IBAction) triggerDisplayNotifications {
    [[JCO instance] displayNotifications];
}

- (void)dealloc {
    self.triggerButtonCrash, self.triggerButtonFeedback, self.triggerButtonNotifications = nil;
    [_locationManager release];
    [super dealloc];
}

- (void)viewDidUnload {
    [_locationManager release];
    [super viewDidUnload];
}


@end

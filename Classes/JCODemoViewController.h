
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol JCOPayloadDataSource;
@protocol JCOCustomDataSource;

@interface JCODemoViewController : UIViewController <JCOCustomDataSource, CLLocationManagerDelegate> {
	IBOutlet UIButton *triggerButtonCrash;
	IBOutlet UIButton *triggerButtonFeedback;	
    IBOutlet UIButton *triggerButtonNotifications;
    CLLocationManager *_locationManager;
}

@property (nonatomic, retain) IBOutlet UIButton *triggerButtonCrash;
@property (nonatomic, retain) IBOutlet UIButton *triggerButtonFeedback;
@property (nonatomic, retain) IBOutlet UIButton *triggerButtonNotifications;

- (IBAction) triggerCrash;
- (IBAction) triggerFeedback;
- (IBAction) triggerDisplayNotifications;


@end



#import <UIKit/UIKit.h>@protocol JCOPayloadDataSource;

@protocol JCOPayloadDataSource;

@interface JCODemoViewController : UIViewController <JCOPayloadDataSource> {
	IBOutlet UIButton *triggerButtonCrash;
	IBOutlet UIButton *triggerButtonFeedback;	
    IBOutlet UIButton *triggerButtonNotifications;	
}

@property (nonatomic, retain) IBOutlet UIButton *triggerButtonCrash;
@property (nonatomic, retain) IBOutlet UIButton *triggerButtonFeedback;
@property (nonatomic, retain) IBOutlet UIButton *triggerButtonNotifications;

- (IBAction) triggerCrash;
- (IBAction) triggerFeedback;
- (IBAction) triggerDisplayNotifications;


@end


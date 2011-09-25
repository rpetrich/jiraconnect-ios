
#import <UIKit/UIKit.h>
#import "JMCCustomDataSource.h"

@interface AngryNerdsViewController : UIViewController <JMCCustomDataSource> {

    IBOutlet UIButton* _nerd;
    IBOutlet UIImageView* _nerdsView;
    IBOutlet UIImageView* _splashView;
}

@property (nonatomic, retain) IBOutlet UIButton *nerd;
@property (nonatomic, retain) IBOutlet UIImageView *nerdsView;
@property (nonatomic, retain) IBOutlet UIImageView *splashView;

- (IBAction) triggerCrash;
- (IBAction) triggerFeedback;
- (IBAction) triggerDisplayNotifications;

-(IBAction)bounceNerd;

@end


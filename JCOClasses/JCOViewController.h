#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "JCOTransport.h"
#import "JCOCustomDataSource.h"
#import "JCORecorder.h"
#import "JCOIssueTransport.h"
#import "JCOReplyTransport.h"
#import "JCOSketchViewControllerDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "CRVActivityView.h"


@interface JCOViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, JCOTransportDelegate, AVAudioRecorderDelegate, JCOSketchViewControllerDelegate, UIAlertViewDelegate,
        CLLocationManagerDelegate, CRVActivityViewDelegate> {

    IBOutlet UITextView *descriptionField;

    IBOutlet UILabel *countdownTimer;
    IBOutlet UIProgressView *progressView;
    IBOutlet UIView *countdownView;
    

    IBOutlet UIImagePickerController *imagePicker;

    IBOutlet UIToolbar* toolbar;

    JCOIssueTransport *_issueTransport;
    JCOReplyTransport *_replyTransport;
    id <JCOCustomDataSource> _payloadDataSource;
    NSMutableArray *_attachments;
    JCORecorder *_recorder;
    JCOIssue *_replyToIssue;

@private
    NSTimer *_timer;
    NSUInteger currentAttachmentItemIndex;
    CGRect descriptionFrame;
    CLLocation *currentLocation;
    CLLocationManager *_locationManager;
    BOOL sendLocationData;
    CRVActivityView *activityView;
    UIBarButtonItem *_voiceButton;
    NSArray* toolbarItems; // holds the first 3 system toolbar items.
}
@property(retain, nonatomic) IBOutlet UITextView *descriptionField;

@property(retain, nonatomic) IBOutlet UIView *countdownView;
@property(retain, nonatomic) IBOutlet UIProgressView *progressView;

@property(retain, nonatomic) IBOutlet UIImagePickerController *imagePicker;
@property(retain, nonatomic) IBOutlet UIToolbar *toolbar;;

@property(retain, nonatomic) JCOIssueTransport *issueTransport;
@property(retain, nonatomic) JCOReplyTransport *replyTransport;
@property(retain, nonatomic) id <JCOCustomDataSource> payloadDataSource;
@property(retain, nonatomic) NSMutableArray *attachments;
// an array of items to attach to the issue
@property(retain, nonatomic) JCORecorder *recorder;
// if this is non-null, then a reply is sent to that issue. Otherwise, a new issue is created.
@property(retain, nonatomic) JCOIssue *replyToIssue;

@property(retain, nonatomic) UIBarButtonItem *voiceButton;

- (IBAction)sendFeedback;

- (void)dismissActivity;

- (IBAction)addScreenshot;

- (IBAction)addVoice;

- (IBAction)dismiss;

@end

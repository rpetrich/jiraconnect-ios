//
//  JCCreateViewController.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//

#import <UIKit/UIKit.h>
#import "JCOTransport.h"
#import <AVFoundation/AVFoundation.h>

@protocol JCOPayloadDataSource;

@interface JCOViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, JCOTransportDelegate, AVAudioRecorderDelegate> {

	IBOutlet UIButton* sendButton;
	IBOutlet UIButton* voiceButton;
	IBOutlet UIButton* screenshotButton;
	IBOutlet UITextView* descriptionField;
	IBOutlet UITextField* subjectField;
	
	IBOutlet UILabel* countdownTimer;
	IBOutlet UIProgressView* progressView;
	IBOutlet UIView* countdownView;
	
	IBOutlet UIImagePickerController* imagePicker;
	JCOTransport* _transport;
    <JCOPayloadDataSource> _payloadDataSource;
	
	
}
@property (retain, nonatomic) IBOutlet UIButton* sendButton;
@property (retain, nonatomic) IBOutlet UIButton* voiceButton;
@property (retain, nonatomic) IBOutlet UIButton* screenshotButton;
@property (retain, nonatomic) IBOutlet UITextView* descriptionField;
@property (retain, nonatomic) IBOutlet UITextField* subjectField;

@property (retain, nonatomic) IBOutlet UIView* countdownView;
@property (retain, nonatomic) IBOutlet UIProgressView* progressView;


@property (retain, nonatomic) IBOutlet UIImagePickerController* imagePicker;
@property (retain, nonatomic) IBOutlet JCOTransport* transport;
@property (retain, nonatomic) IBOutlet id<JCOPayloadDataSource> payloadDataSource;

- (IBAction) sendFeedback;
- (IBAction) addScreenshot;
- (IBAction) addVoice;
- (IBAction) dismiss;

@end

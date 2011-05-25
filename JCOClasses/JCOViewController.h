//
//  JCCreateViewController.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "JCOTransport.h"
#import "JCOCustomDataSource.h"
#import "JCORecorder.h"
#import "JCOIssueTransport.h"
#import "JCOReplyTransport.h"
#import "JCOSketchViewControllerDelegate.h"


@interface JCOToolbar : UIToolbar {

}
@end

@interface JCOViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, JCOTransportDelegate, AVAudioRecorderDelegate, JCOSketchViewControllerDelegate, UIAlertViewDelegate> {

	IBOutlet UIButton* sendButton;
	IBOutlet UIButton* voiceButton;
	IBOutlet UIButton* screenshotButton;

    IBOutlet UITextField* subjectField;
    IBOutlet UITextView* descriptionField;
    IBOutlet UIToolbar* attachmentBar;
    IBOutlet UIImageView* buttonBar;

	IBOutlet UILabel* countdownTimer;
	IBOutlet UIProgressView* progressView;
	IBOutlet UIActivityIndicatorView* activityIndicator;
	IBOutlet UIView* countdownView;
	
	IBOutlet UIImagePickerController* imagePicker;
	JCOIssueTransport*_issueTransport;
	JCOReplyTransport* _replyTransport;
    <JCOCustomDataSource> _payloadDataSource;
    NSMutableArray *_attachments;
    JCORecorder* _recorder;
    JCOIssue * _replyToIssue;
    

}
@property (retain, nonatomic) IBOutlet UIButton* sendButton;
@property (retain, nonatomic) IBOutlet UIButton* voiceButton;
@property (retain, nonatomic) IBOutlet UIButton* screenshotButton;
@property (retain, nonatomic) IBOutlet UITextView* descriptionField;
@property (retain, nonatomic) IBOutlet UITextField* subjectField;
@property (retain, nonatomic) IBOutlet UIToolbar* attachmentBar;
@property (retain, nonatomic) IBOutlet UIImageView* buttonBar;

@property (retain, nonatomic) IBOutlet UIView* countdownView;
@property (retain, nonatomic) IBOutlet UIProgressView* progressView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (retain, nonatomic) IBOutlet UIImagePickerController* imagePicker;

@property (retain, nonatomic) JCOIssueTransport* issueTransport;
@property (retain, nonatomic) JCOReplyTransport* replyTransport;
@property (retain, nonatomic) id<JCOCustomDataSource> payloadDataSource;
@property (retain, nonatomic) NSMutableArray* attachments; // an array of items to attach to the issue
@property (retain, nonatomic) JCORecorder* recorder;
// if this is non-null, then a reply is sent to that issue. Otherwise, a new issue is created.
@property (retain, nonatomic) JCOIssue * replyToIssue;

- (IBAction) sendFeedback;
- (IBAction) addScreenshot;
- (IBAction) addVoice;
- (IBAction) dismiss;

@end

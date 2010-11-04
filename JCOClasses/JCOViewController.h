//
//  JCCreateViewController.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCOTransport.h"
#import <AVFoundation/AVFoundation.h>


@interface JCOViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, JCOTransportDelegate, AVAudioRecorderDelegate> {

	IBOutlet UIButton* sendButton;
	IBOutlet UIButton* voiceButton;
	IBOutlet UIButton* screenshotButton;
	IBOutlet UITextView* descriptionField;
	IBOutlet UITextField* subjectField;
	IBOutlet UIImagePickerController* imagePicker;
	JCOTransport* _transport;
	
}
@property (retain, nonatomic) IBOutlet UIButton* sendButton;
@property (retain, nonatomic) IBOutlet UIButton* voiceButton;
@property (retain, nonatomic) IBOutlet UIButton* screenshotButton;
@property (retain, nonatomic) IBOutlet UITextView* descriptionField;
@property (retain, nonatomic) IBOutlet UITextField* subjectField;
@property (retain, nonatomic) IBOutlet UIImagePickerController* imagePicker;
@property (retain, nonatomic) IBOutlet JCOTransport* transport;

- (IBAction) sendFeedback;
- (IBAction) addScreenshot;
- (IBAction) addVoice;
- (IBAction) dismiss;

@end

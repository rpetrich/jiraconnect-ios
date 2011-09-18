/**
   Copyright 2011 Atlassian Software

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
**/
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Core/JMCTransport.h"
#import "JMCCustomDataSource.h"
#import "Core/JMCRecorder.h"
#import "Core/JMCIssueTransport.h"
#import "Core/JMCReplyTransport.h"
#import "Core/JMCSketchViewControllerDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "CRVActivityView.h"


@interface JMCViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, JMCTransportDelegate, AVAudioRecorderDelegate, JMCSketchViewControllerDelegate, UIAlertViewDelegate,
        CLLocationManagerDelegate, CRVActivityViewDelegate> {

    IBOutlet UITextView *descriptionField;

    IBOutlet UILabel *countdownTimer;
    IBOutlet UIProgressView *progressView;
    IBOutlet UIView *countdownView;
    

    IBOutlet UIImagePickerController *imagePicker;

    IBOutlet UIToolbar* toolbar;

    JMCIssueTransport *_issueTransport;
    JMCReplyTransport *_replyTransport;
    id <JMCCustomDataSource> _payloadDataSource;
    NSMutableArray *_attachments;
    JMCIssue *_replyToIssue;

@private
    NSTimer *_timer;
    NSUInteger currentAttachmentItemIndex;
    CGRect descriptionFrame;
    CLLocation *currentLocation;
    CLLocationManager *_locationManager;
    BOOL sendLocationData;
    CRVActivityView *activityView;
    UIBarButtonItem *_voiceButton;
    NSArray *systemToolbarItems; // holds the 3 system toolbar items.
}
@property(retain, nonatomic) IBOutlet UITextView *descriptionField;

@property(retain, nonatomic) IBOutlet UIView *countdownView;
@property(retain, nonatomic) IBOutlet UIProgressView *progressView;

@property(retain, nonatomic) IBOutlet UIImagePickerController *imagePicker;
@property(retain, nonatomic) IBOutlet UIToolbar *toolbar;;

@property(retain, nonatomic) JMCIssueTransport *issueTransport;
@property(retain, nonatomic) JMCReplyTransport *replyTransport;
@property(retain, nonatomic) id <JMCCustomDataSource> payloadDataSource;

// an array of items to attach to the issue
@property(retain, nonatomic) NSMutableArray *attachments;
// if this is non-null, then a reply is sent to that issue. Otherwise, a new issue is created.
@property(retain, nonatomic) JMCIssue *replyToIssue;

@property(retain, nonatomic) UIBarButtonItem *voiceButton;

- (IBAction)sendFeedback;

- (void)dismissActivity;

- (IBAction)addScreenshot;

- (IBAction)addVoice;

- (IBAction)dismiss;

@end

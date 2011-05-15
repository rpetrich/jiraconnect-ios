//
//  JCCreateViewController.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//

#import "JCOViewController.h"
#import "JCORecorder.h"
#import "JCOCustomDataSource.h"
#import "JCOIssueTransport.h"
#import "JCOReplyTransport.h"
#import "UIImage+Resize.h"

@interface JCOViewController ()

- (void)setVoiceButtonTitleWithDuration:(float)duration;

@end

@implementation JCOViewController

NSTimer *_timer;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.issueTransport = [[JCOIssueTransport alloc] init];
    self.replyTransport = [[JCOReplyTransport alloc] init];
    self.recorder = [[JCORecorder alloc] init];
    self.recorder.recorder.delegate = self;
    self.countdownView.layer.cornerRadius = 7.0;

    NSLog(@"View Did load!! %@", self);
}

- (void)viewDidAppear:(BOOL)animated {
    [self setVoiceButtonTitleWithDuration:[_recorder previousDuration]];

}

- (IBAction)dismiss {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)addScreenshot {
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)setVoiceButtonTitleWithDuration:(float)duration {

    NSString *durationStr = [NSString stringWithFormat:@"%.2f\"", duration];
    [self.voiceButton setTitle:durationStr forState:UIControlStateNormal];
    [self.voiceButton setTitle:durationStr forState:UIControlStateSelected];
    [self.voiceButton setTitle:durationStr forState:UIControlStateHighlighted];
}

- (void)updateProgress:(NSTimer *)theTimer {
    float currentDuration = [_recorder currentDuration];
    float progress = (currentDuration / _recorder.recordTime);
    self.progressView.progress = progress;
    [self setVoiceButtonTitleWithDuration:currentDuration];
}

- (void)hideAudioProgress {
    self.countdownView.hidden = YES;
    self.progressView.progress = 0;
    [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"button_Record.png"] forState:UIControlStateNormal];
    [_timer invalidate];
}

- (IBAction)addVoice {

    if (_recorder.recorder.recording) {

        [_recorder stop];
        // update the label
        [self setVoiceButtonTitleWithDuration:[_recorder previousDuration]];

    } else {
        [_recorder start];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
        self.progressView.progress = 0;

        self.countdownView.hidden = NO;
        [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"button_Record-OnAir.png"] forState:UIControlStateNormal];
    }
}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)success {
    [self setVoiceButtonTitleWithDuration:[_recorder previousDuration]];
    [self hideAudioProgress];

}

- (IBAction)sendFeedback {

    self.issueTransport.delegate = self;
    NSDictionary *payloadData = nil;
    NSDictionary *customFields = nil;

    if ([self.payloadDataSource respondsToSelector:@selector(payloadFor:)]) {
        payloadData = [self.payloadDataSource payloadFor:self.subjectField.text];
    }
    if ([self.payloadDataSource respondsToSelector:@selector(customFieldsFor:)]) {
        customFields = [self.payloadDataSource customFieldsFor:self.subjectField.text];
    }

    if (self.replyToIssue) {
        [self.replyTransport sendReply:self.replyToIssue
                           description:self.descriptionField.text
                            screenshot:_image
                             voiceData:[_recorder audioData]
                               payload:payloadData
                                fields:customFields];
    } else {
        [self.issueTransport send:self.subjectField.text
                      description:self.descriptionField.text
                       screenshot:_image
                        voiceData:[_recorder audioData]
                          payload:payloadData
                           fields:customFields];
    }
    self.descriptionField.text = nil;
    self.subjectField.text = nil;
    [self setVoiceButtonTitleWithDuration:0.0];
    // TODO: also reset _recorder
    [[self.screenshotButton viewWithTag:20] removeFromSuperview];

}

- (void)transportDidFinish {

    //TODO: error handling and reporting!
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *origImg = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissModalViewControllerAnimated:YES];
    [self.screenshotButton setAutoresizesSubviews:NO];

    CGSize size = self.screenshotButton.frame.size;

    UIImage *newImage = [origImg thumbnailImage:(int)size.width
                              transparentBorder:0
                                   cornerRadius:5
                           interpolationQuality:kCGInterpolationHigh];

    UIImageView *imgView = [[UIImageView alloc] initWithImage:newImage];
    imgView.tag = 20;
    [[self.screenshotButton viewWithTag:20] removeFromSuperview];// remove previous image, if any?
    [self.screenshotButton addSubview:imgView];
    [imgView release];
    [self.screenshotButton setTitle:nil forState:UIControlStateNormal];
    self.image = origImg;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark end

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark end

#pragma mark UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


#pragma mark end

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@synthesize sendButton, voiceButton, screenshotButton, descriptionField, subjectField, countdownView, progressView, imagePicker;
@synthesize issueTransport = _issueTransport, replyTransport = _replyTransport, payloadDataSource = _payloadDataSource, image = _image, recorder = _recorder, replyToIssue = _replyToIssue;

- (void)dealloc {
    self.image,
            self.recorder,
            self.sendButton,
            self.imagePicker,
            self.voiceButton,
            self.progressView,
            self.subjectField,
            self.replyToIssue,
            self.countdownView,
            self.issueTransport,
            self.replyTransport,
            self.screenshotButton,
            self.descriptionField,
            self.payloadDataSource = nil;
    [super dealloc];
}

// TODO: DRY this up.
- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    self.image,
            self.recorder,
            self.sendButton,
            self.imagePicker,
            self.voiceButton,
            self.progressView,
            self.subjectField,
            self.replyToIssue,
            self.countdownView,
            self.issueTransport,
            self.replyTransport,
            self.screenshotButton,
            self.descriptionField,
            self.payloadDataSource = nil;
    [super viewDidUnload];
    NSLog(@"View Did UNload!!");
}

@end

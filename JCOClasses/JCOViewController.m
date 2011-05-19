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

@implementation JCOToolbar

- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"buttonbase.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end

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
    self.descriptionField.layer.cornerRadius = 7.0;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationItem.leftBarButtonItem =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                          target:self
                                                          action:@selector(dismiss)];
    self.navigationItem.title = @"Report Issue";

    self.images = [NSMutableArray arrayWithCapacity:2];
    self.bar.items = nil;
    self.bar.autoresizesSubviews = YES;
    self.bar.layer.cornerRadius = 5.0;
    CGRect frame = self.bar.frame;
    self.bar.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 70);
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
    [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"button_record.png"] forState:UIControlStateNormal];
    [[self.voiceButton viewWithTag:2] removeFromSuperview];
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
        // TODO get at least one more image to make this ani smoother
        UIImage *activeImg = [UIImage imageNamed:@"icon_record_active.png"];
        UIImage *pulseImg = [UIImage imageNamed:@"icon_record_pulse.png"];

        self.voiceButton.imageView.image = activeImg;
        UIImageView *imgView = [[UIImageView alloc] initWithImage:activeImg];

        NSMutableArray *sprites = [NSMutableArray arrayWithCapacity:8];
        for (int i = 1; i < 9; i++) {
            NSString *sprintName = [@"icon_record_" stringByAppendingFormat:@"%d.png", i];
            UIImage *img = [UIImage imageNamed:sprintName];
            [sprites addObject:img];
        }

        imgView.animationImages = sprites;
        imgView.animationDuration = 0.85f;
        

        CGRect buttFrame = self.voiceButton.frame;
        float x = (buttFrame.size.width/2.0f) - (activeImg.size.width/2.0f) - 1;
        imgView.tag = 2;
        [imgView startAnimating];

        imgView.frame = CGRectMake(x, 5, activeImg.size.width, activeImg.size.height);
        [self.voiceButton addSubview:imgView];
        [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"button_blank.png"] forState:UIControlStateNormal];
        [imgView release];
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
                            images:self.images
                             voiceData:[_recorder audioData]
                               payload:payloadData
                                fields:customFields];
    } else {
        [self.issueTransport send:self.subjectField.text
                      description:self.descriptionField.text
                       images:self.images
                        voiceData:[_recorder audioData]
                          payload:payloadData
                           fields:customFields];
    }
}

- (void)transportDidFinish {

    //TODO: error handling and reporting!
    [self dismissModalViewControllerAnimated:YES];

    self.descriptionField.text = @"";
    self.subjectField.text = @"";
    [self setVoiceButtonTitleWithDuration:0.0];
    // TODO: also reset _recorder and set the text on the capture button
    [[self.screenshotButton viewWithTag:20] removeFromSuperview];
    [self.images removeAllObjects];
    [self.bar setItems:nil];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *origImg = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissModalViewControllerAnimated:YES];
    [self.screenshotButton setAutoresizesSubviews:NO];

    CGSize  size = CGSizeMake(40, self.bar.frame.size.height);
    UIImage *newImage = [origImg resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                      bounds:size
                                        interpolationQuality:kCGInterpolationHigh];

    [self.bar setClipsToBounds:YES];

    CGRect buttonFrame = CGRectMake(0, 0, newImage.size.width, newImage.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button setImage:newImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(itemTouch:) forControlEvents:UIControlEventTouchUpInside];
    button.imageView.layer.cornerRadius = 5.0;

    UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.tag = [self.images count];

    NSMutableArray *buttonItems = [NSMutableArray arrayWithArray:self.bar.items];
    [buttonItems addObject:buttonItem];
    [self.bar setItems:buttonItems];

    [self.images addObject:origImg];

    [buttonItem release];
    [button release];

}

-(void) itemTouch:(UIButton *)touch {
    // delete that button, both from the bar, and the images array
    NSUInteger index = (u_int )touch.tag;

    [self.images removeObjectAtIndex:index];

    NSMutableArray *buttonItems = [NSMutableArray arrayWithArray:self.bar.items];
    [buttonItems removeObjectAtIndex:index];

    // re-tag all buttons...
    for (int i = 0; i < [buttonItems count]; i++) {
        UIBarButtonItem* buttonItem = (UIBarButtonItem *)[buttonItems objectAtIndex:i];
        buttonItem.customView.tag = i;
    }

    [self.bar setItems:buttonItems animated:YES];

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

@synthesize sendButton, voiceButton, screenshotButton,
descriptionField, subjectField, countdownView, progressView,
imagePicker, bar;

@synthesize issueTransport = _issueTransport,
            replyTransport = _replyTransport,
            payloadDataSource = _payloadDataSource,
            images = _images,
            recorder = _recorder,
            replyToIssue = _replyToIssue;


- (void)dealloc {
    self.bar,
            self.images,
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
    self.bar,
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
}

@end

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
#import "Core/UIView+Additions.h"
#import "JCOAttachmentItem.h"
#import "JCOSketchViewController.h"

@implementation JCOToolbar

- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"buttonbase.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end

@interface JCOViewController ()

-(void) setVoiceButtonTitleWithDuration:(float)duration;
-(void) addAttachmentItem:(JCOAttachmentItem *)item withIcon:(UIImage *)icon;
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

    self.attachments = [NSMutableArray arrayWithCapacity:1];
    self.attachmentBar.clipsToBounds = YES;
    self.attachmentBar.items = nil;
    self.attachmentBar.autoresizesSubviews = YES;

    // layout views
    self.subjectField.top = [self.navigationController.toolbar height] + 10;
    self.descriptionField.top = self.subjectField.bottom + 10;
    self.attachmentBar.top = self.descriptionField.bottom + 10;
    self.attachmentBar.height = self.buttonBar.top - self.descriptionField.bottom - 10;
    self.activityIndicator.center = self.descriptionField.center;
}

- (void)viewDidAppear:(BOOL)animated {
    [self setVoiceButtonTitleWithDuration:[_recorder previousDuration]];
}

- (IBAction)dismiss {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)dismissKeyboard {
    [self.descriptionField resignFirstResponder];
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
        UIImage *activeImg = [UIImage imageNamed:@"icon_record_active.png"];
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


    JCOAttachmentItem *attachment = [[JCOAttachmentItem alloc] initWithName:@"recording"
                                                                       data:[_recorder audioData]
                                                                       type:JCOAttachmentTypeRecording
                                                                contentType:@"audio/x-caf"
                                                                   filenameFormat:@"recording-%d.caf"];


    UIImage *newImage = [UIImage imageNamed:@"icon_record_2.png"];
    [self addAttachmentItem:attachment withIcon:newImage];
    [attachment release];
}

- (void)addAttachmentItem:(JCOAttachmentItem *)attachment withIcon:(UIImage *)icon {

    CGRect buttonFrame = CGRectMake(0, 0, icon.size.width, icon.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button setImage:icon forState:UIControlStateNormal];
    [button addTarget:self action:@selector(attachmentTapped:) forControlEvents:UIControlEventTouchUpInside];

    button.imageView.layer.cornerRadius = 5.0;
    button.titleLabel.frame = CGRectMake(0, button.height - 12, [button width], 15);
    button.titleLabel.hidden = NO;
    NSLog(@"button title = %@", button.titleLabel);
    button.backgroundColor = [UIColor redColor];

    button.titleLabel.text = @"test";

    UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.tag = [self.attachments count];

    NSMutableArray *buttonItems = [NSMutableArray arrayWithArray:self.attachmentBar.items];
    [buttonItems addObject:buttonItem];
    [self.attachmentBar setItems:buttonItems];

    [self.attachments addObject:attachment];

    [buttonItem release];
    [button release];
}

- (void)addImageAttachmentItem:(UIImage *)origImg
{
    JCOAttachmentItem *attachment = [[JCOAttachmentItem alloc] initWithName:@"screenshot"
                                                                       data:UIImagePNGRepresentation(origImg)
                                                                       type:JCOAttachmentTypeImage
                                                                contentType:@"image/png"
                                                             filenameFormat:@"screenshot-%d.png"];

    CGSize  size = CGSizeMake(40, self.attachmentBar.frame.size.height);
    UIImage *newImage = [origImg resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                      bounds:size
                                        interpolationQuality:kCGInterpolationHigh];


    [self addAttachmentItem:attachment withIcon:newImage];
    [attachment release];
}

-(void) attachmentTapped:(UIButton *)touch {
    // delete that button, both from the bar, and the images array
    NSUInteger index = (u_int )touch.tag;

    JCOAttachmentItem *attachment = [self.attachments objectAtIndex:index];
    if (attachment.type == JCOAttachmentTypeImage) {
        JCOSketchViewController *sketchViewController = [[[JCOSketchViewController alloc] initWithNibName:@"JCOSketchViewController" bundle:nil] autorelease];
        // get the original image, wire it up to the sketch controller
        sketchViewController.image = [[[UIImage alloc] initWithData:attachment.data] autorelease];
        sketchViewController.imageId = [NSNumber numberWithUnsignedInteger:index]; // set this image's id. just the index in the array
        sketchViewController.delegate = self;
        [self presentModalViewController:sketchViewController animated:YES];
    } else {
        NSLog(@"TODO: play in AudioPlayer?");
        //TODO or wait for a long press, then delete?
    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    [self dismissModalViewControllerAnimated:YES];
    
    [self.screenshotButton setAutoresizesSubviews:NO];
    UIImage *origImg = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];

    if (origImg.size.height > self.view.height) {
        // resize image... its too huge!
        CGSize size = origImg.size;
        float ratio = self.view.height/size.height;
        CGSize smallerSize = CGSizeMake(ratio*size.width, ratio*size.height);
        origImg = [origImg resizedImage:smallerSize interpolationQuality:kCGInterpolationMedium];
    }
    
    [self addImageAttachmentItem:origImg];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark end

#pragma mark JCOSketchViewControllerDelegate

- (void)sketchController:(UIViewController *)controller didFinishSketchingImage:(UIImage *)image withId:(NSNumber *)imageId
{
    [self dismissModalViewControllerAnimated:YES];
    NSUInteger index = [imageId unsignedIntegerValue];
    JCOAttachmentItem *attachment = [self.attachments objectAtIndex:index];
    attachment.data = UIImagePNGRepresentation(image);

    // also update the icon in the toolbar
    CGSize  size = CGSizeMake(40, self.attachmentBar.frame.size.height);
    UIImage *iconImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                      bounds:size
                                        interpolationQuality:kCGInterpolationHigh];
    UIBarButtonItem* item = [self.attachmentBar.items objectAtIndex:index];
    ((UIButton*)item.customView).imageView.image = iconImage;
}

- (void)sketchControllerDidCancel:(UIViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sketchController:(UIViewController *)controller didDeleteImageWithId:(NSNumber *)imageId
{
    [self dismissModalViewControllerAnimated:YES];

    NSUInteger index = [imageId unsignedIntegerValue];
    [self.attachments removeObjectAtIndex:index];

    NSMutableArray *buttonItems = [NSMutableArray arrayWithArray:self.attachmentBar.items];
    [buttonItems removeObjectAtIndex:index];

    // re-tag all buttons...
    for (int i = 0; i < [buttonItems count]; i++)
    {
        UIBarButtonItem *buttonItem = (UIBarButtonItem *)[buttonItems objectAtIndex:(NSUInteger)i];
        buttonItem.customView.tag = i;
    }

    [self.attachmentBar setItems:buttonItems animated:YES];
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
    self.navigationItem.rightBarButtonItem = nil;
    
    [UIView beginAnimations:@"resize description" context:nil];
    float height = self.attachmentBar.top - (self.subjectField.bottom) - 20;
    CGRect frame = CGRectMake(10, self.subjectField.bottom + 10, self.view.width - 20, height);
    self.descriptionField.frame = frame;
    self.descriptionField.layer.cornerRadius = 7.0;
    NSRange range = {0, 0};
    [self.descriptionField scrollRangeToVisible:range];
    [UIView commitAnimations];

}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                          target:self
                                                          action:@selector(dismissKeyboard)];
    [UIView beginAnimations:@"resize description" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect frame = CGRectMake(0, self.navigationController.toolbar.height, self.view.width, 200);
    self.descriptionField.frame = frame;
    self.descriptionField.layer.cornerRadius = 0;
    [UIView commitAnimations];

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
        [self.replyTransport sendReply:self.replyToIssue description:self.descriptionField.text images:self.attachments payload:payloadData fields:customFields];
    } else {
        [self.issueTransport send:self.subjectField.text description:self.descriptionField.text images:self.attachments payload:payloadData fields:customFields];
    }
    self.activityIndicator.hidesWhenStopped = TRUE;
    [self.activityIndicator startAnimating];
}

- (void)transportDidFinish {

    [self.activityIndicator stopAnimating];

    [self dismissModalViewControllerAnimated:YES];

    self.descriptionField.text = @"";
    self.subjectField.text = @"";
    [self setVoiceButtonTitleWithDuration:0.0];
    [[self.screenshotButton viewWithTag:20] removeFromSuperview];
    [self.attachments removeAllObjects];
    [self.attachmentBar setItems:nil];
}

- (void)transportDidFinishWithError:(NSError*)error {
    [self.activityIndicator stopAnimating];
}

#pragma mark end

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//    return YES;
}

@synthesize sendButton, voiceButton, screenshotButton, descriptionField, subjectField, countdownView, progressView, imagePicker, attachmentBar, activityIndicator, buttonBar;

@synthesize issueTransport = _issueTransport,
            replyTransport = _replyTransport,
            payloadDataSource = _payloadDataSource,
            attachments = _attachments,
            recorder = _recorder,
            replyToIssue = _replyToIssue;


- (void)releaseMembers {
    // Release any retained subviews of the main view.
    self.attachmentBar,
            self.recorder,
            self.buttonBar,
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
            self.activityIndicator,
            self.payloadDataSource = nil;
}

- (void)dealloc {
    [self releaseMembers];
    [super dealloc];
}

- (void)viewDidUnload {
    [self releaseMembers];
    [super viewDidUnload];
}

@end

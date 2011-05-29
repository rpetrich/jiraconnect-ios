#import "JCOViewController.h"
#import "UIImage+Resize.h"
#import "Core/UIView+Additions.h"
#import "JCOAttachmentItem.h"
#import "JCOSketchViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation JCOToolbar

- (void)drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:@"buttonbase.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end

@interface JCOViewController ()


- (void)addAttachmentItem:(JCOAttachmentItem *)attachment withIcon:(UIImage *)icon title:(NSString *)title;

@end

@implementation JCOViewController

NSTimer *_timer;
NSUInteger currentAttachmentItemIndex = 0;
CGRect descriptionFrame;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.issueTransport = [[[JCOIssueTransport alloc] init] autorelease];
        self.replyTransport = [[[JCOReplyTransport alloc] init] autorelease];
        self.recorder = [[[JCORecorder alloc] init] autorelease];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // layout views
    self.recorder.recorder.delegate = self;
    self.countdownView.layer.cornerRadius = 7.0;
    self.descriptionField.layer.cornerRadius = 7.0;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    self.navigationItem.leftBarButtonItem =
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                           target:self
                                                           action:@selector(dismiss)] autorelease];
    self.navigationItem.title = NSLocalizedString(@"Feedback", "Title of the feedback controller");

    self.attachments = [NSMutableArray arrayWithCapacity:1];
    self.attachmentBar.clipsToBounds = YES;
    self.attachmentBar.items = nil;
    self.attachmentBar.autoresizesSubviews = YES;

    float descriptionFieldInset = 15;
    self.descriptionField.top = 44 + descriptionFieldInset;
    self.descriptionField.width = self.view.width - (descriptionFieldInset * 2.0);
    descriptionFrame = self.descriptionField.frame;
    self.attachmentBar.top = self.descriptionField.bottom + descriptionFieldInset;
    self.attachmentBar.height = self.buttonBar.top - self.descriptionField.bottom - descriptionFieldInset;
    self.activityIndicator.center = self.descriptionField.center;

    // align the button titles nicer
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 5, 0);
    self.screenshotButton.titleEdgeInsets = insets;
    self.voiceButton.titleEdgeInsets = insets;
    self.sendButton.titleEdgeInsets = insets;
}


- (IBAction)dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)dismissKeyboard
{
    [self.descriptionField resignFirstResponder];
}

- (IBAction)addScreenshot
{
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)updateProgress:(NSTimer *)theTimer
{
    float currentDuration = [_recorder currentDuration];
    float progress = (currentDuration / _recorder.recordTime);
    self.progressView.progress = progress;
}

- (void)hideAudioProgress
{
    self.countdownView.hidden = YES;
    self.progressView.progress = 0;
    [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"button_record.png"] forState:UIControlStateNormal];
    [[self.voiceButton viewWithTag:2] removeFromSuperview];
    [_timer invalidate];
}

- (IBAction)addVoice
{

    if (_recorder.recorder.recording) {
        [_recorder stop];

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
        float x = (buttFrame.size.width / 2.0f) - (activeImg.size.width / 2.0f) - 1;
        imgView.tag = 2;
        [imgView startAnimating];

        imgView.frame = CGRectMake(x, 5, activeImg.size.width, activeImg.size.height);
        [self.voiceButton addSubview:imgView];
        [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"button_blank.png"] forState:UIControlStateNormal];
        [imgView release];
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)success
{
    float duration = [_recorder previousDuration];
    [self hideAudioProgress];


    JCOAttachmentItem *attachment = [[JCOAttachmentItem alloc] initWithName:@"recording"
                                                                       data:[_recorder audioData]
                                                                       type:JCOAttachmentTypeRecording
                                                                contentType:@"audio/x-caf"
                                                             filenameFormat:@"recording-%d.caf"];


    UIImage *newImage = [UIImage imageNamed:@"icon_record_2.png"];
    [self addAttachmentItem:attachment withIcon:newImage title:[NSString stringWithFormat:@"%.2f\"", duration]];
    [attachment release];
}

- (void)addAttachmentItem:(JCOAttachmentItem *)attachment withIcon:(UIImage *)icon title:(NSString *)title
{

    CGRect buttonFrame = CGRectMake(0, 0, icon.size.width, icon.size.height);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = buttonFrame;

    [button addTarget:self action:@selector(attachmentTapped:) forControlEvents:UIControlEventTouchUpInside];
    button.imageView.layer.cornerRadius = 5.0;

    if (title) {
        UIFont *font = [UIFont systemFontOfSize:12.0];
        CGSize size = [title sizeWithFont:font];
        button.titleLabel.textColor = [UIColor whiteColor];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = font;
        button.titleLabel.textAlignment = UITextAlignmentCenter;
        [button setTitleEdgeInsets:UIEdgeInsetsMake(-4.0, -icon.size.width, -35.0, -4.0)];
        [button setImageEdgeInsets:UIEdgeInsetsMake(-10.0, 0.0, 0.0, -button.titleLabel.bounds.size.width)]; // Right inset is the negative of text bounds width.
        button.titleLabel.hidden = NO;

        [button.layer setBorderWidth:1.0f];
        [button.layer setBorderColor:[[UIColor grayColor] CGColor]];
        button.layer.cornerRadius = 5.0f;
        button.height += size.height;
        button.width = size.width + 5;

    }
    [button setImage:icon forState:UIControlStateNormal];


    UIBarButtonItem *buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];

    button.tag = [self.attachments count];

    NSMutableArray *buttonItems = [NSMutableArray arrayWithArray:self.attachmentBar.items];
    [buttonItems addObject:buttonItem];
    [self.attachmentBar setItems:buttonItems];
    [self.attachments addObject:attachment];

}

- (void)addImageAttachmentItem:(UIImage *)origImg
{
    JCOAttachmentItem *attachment = [[JCOAttachmentItem alloc] initWithName:@"screenshot"
                                                                       data:UIImagePNGRepresentation(origImg)
                                                                       type:JCOAttachmentTypeImage
                                                                contentType:@"image/png"
                                                             filenameFormat:@"screenshot-%d.png"];

    CGSize size = CGSizeMake(40, self.attachmentBar.frame.size.height);
    UIImage *newImage = [origImg resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                      bounds:size
                                        interpolationQuality:kCGInterpolationHigh];


    [self addAttachmentItem:attachment withIcon:newImage title:nil];
    [attachment release];
}

- (void)removeAttachmentItemAtIndex:(NSUInteger)index
{

    [self.attachments removeObjectAtIndex:index];
    NSMutableArray *buttonItems = [NSMutableArray arrayWithArray:self.attachmentBar.items];
    [buttonItems removeObjectAtIndex:index];
    // re-tag all buttons... with their new index
    for (int i = 0; i < [buttonItems count]; i++) {
        UIBarButtonItem *buttonItem = (UIBarButtonItem *) [buttonItems objectAtIndex:(NSUInteger) i];
        buttonItem.customView.tag = i;
    }

    [self.attachmentBar setItems:buttonItems animated:YES];
}

- (void)attachmentTapped:(UIButton *)touch
{
    // delete that button, both from the bar, and the images array
    NSUInteger index = (u_int) touch.tag;

    JCOAttachmentItem *attachment = [self.attachments objectAtIndex:index];
    if (attachment.type == JCOAttachmentTypeImage) {
        JCOSketchViewController *sketchViewController = [[[JCOSketchViewController alloc] initWithNibName:@"JCOSketchViewController" bundle:nil] autorelease];
        // get the original image, wire it up to the sketch controller
        sketchViewController.image = [[[UIImage alloc] initWithData:attachment.data] autorelease];
        sketchViewController.imageId = [NSNumber numberWithUnsignedInteger:index]; // set this image's id. just the index in the array
        sketchViewController.delegate = self;
        [self presentModalViewController:sketchViewController animated:YES];
    } else {
        UIAlertView *view =
                [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RemoveRecording", @"Remove recording title") message:NSLocalizedString(@"AlertBeforeDeletingRecording", @"Warning message before deleting a recording.") delegate:self
                                 cancelButtonTitle:NSLocalizedString(@"No", @"") otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
        currentAttachmentItemIndex = index;
        [view show];
        [view release];

    }
}

#pragma mark UIAlertViewDelelgate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // dismiss modal dialog.
    if (buttonIndex == 1) {
        [self removeAttachmentItemAtIndex:currentAttachmentItemIndex];
    }
    currentAttachmentItemIndex = 0;
}


#pragma end

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    [self dismissModalViewControllerAnimated:YES];

    [self.screenshotButton setAutoresizesSubviews:NO];
    UIImage *origImg = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];

    if (origImg.size.height > self.view.height) {
        // resize image... its too huge!
        CGSize size = origImg.size;
        float ratio = self.view.height / size.height;
        CGSize smallerSize = CGSizeMake(ratio * size.width, ratio * size.height);
        origImg = [origImg resizedImage:smallerSize interpolationQuality:kCGInterpolationMedium];
    }

    [self addImageAttachmentItem:origImg];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
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
    CGSize size = CGSizeMake(40, self.attachmentBar.frame.size.height);
    UIImage *iconImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                     bounds:size
                                       interpolationQuality:kCGInterpolationHigh];
    UIBarButtonItem *item = [self.attachmentBar.items objectAtIndex:index];
    ((UIButton *) item.customView).imageView.image = iconImage;
}

- (void)sketchControllerDidCancel:(UIViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sketchController:(UIViewController *)controller didDeleteImageWithId:(NSNumber *)imageId
{
    [self dismissModalViewControllerAnimated:YES];
    [self removeAttachmentItemAtIndex:[imageId unsignedIntegerValue]];
}


#pragma mark end

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark end

#pragma mark UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView
{


    [UIView beginAnimations:@"resize description" context:nil];
    self.navigationItem.rightBarButtonItem = nil;
    self.descriptionField.frame = descriptionFrame;
    self.descriptionField.layer.cornerRadius = 7.0;
    NSRange range = {0, 0};
    [self.descriptionField scrollRangeToVisible:range];
    [UIView commitAnimations];

}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem =
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                           target:self
                                                           action:@selector(dismissKeyboard)] autorelease];
    [UIView beginAnimations:@"resize description" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect frame = CGRectMake(0, self.navigationController.toolbar.height, self.view.width, 200);
    self.descriptionField.frame = frame;
    self.descriptionField.layer.cornerRadius = 0;
    [UIView commitAnimations];

}

- (IBAction)sendFeedback
{

    self.issueTransport.delegate = self;
    NSDictionary *payloadData = nil;
    NSDictionary *customFields = nil;

    if ([self.payloadDataSource respondsToSelector:@selector(payloadFor:)]) {
        payloadData = [self.payloadDataSource payloadFor:self.descriptionField.text];
    }
    if ([self.payloadDataSource respondsToSelector:@selector(customFieldsFor:)]) {
        customFields = [self.payloadDataSource customFieldsFor:self.descriptionField.text];
    }

    if (self.replyToIssue) {
        [self.replyTransport sendReply:self.replyToIssue description:self.descriptionField.text images:self.attachments payload:payloadData fields:customFields];
    } else {
        // use the first 100 chars of the description as the issue titlle
        NSString *description = self.descriptionField.text;
        u_int  length = 80;
        u_int toIndex = [description length] > length ? length : [description length];
        NSString *truncationMarker = [description length] > length ? @"..." : @"";
        [self.issueTransport send:[[description substringToIndex:toIndex] stringByAppendingString:truncationMarker]
                      description:self.descriptionField.text
                           images:self.attachments
                          payload:payloadData
                           fields:customFields];
    }
    self.activityIndicator.hidesWhenStopped = TRUE;
    [self.activityIndicator startAnimating];
}

- (void)transportDidFinish
{

    [self.activityIndicator stopAnimating];

    [self dismissModalViewControllerAnimated:YES];

    self.descriptionField.text = @"";
    [[self.screenshotButton viewWithTag:20] removeFromSuperview];
    [self.attachments removeAllObjects];
    [self.attachmentBar setItems:nil];
}

- (void)transportDidFinishWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
}

#pragma mark end

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//    return YES;
}

@synthesize sendButton, voiceButton, screenshotButton, descriptionField, countdownView, progressView, imagePicker, attachmentBar, activityIndicator, buttonBar;

@synthesize issueTransport = _issueTransport, replyTransport = _replyTransport, payloadDataSource = _payloadDataSource, attachments = _attachments, recorder = _recorder, replyToIssue = _replyToIssue;

- (void)dealloc
{
// Release any retained subviews of the main view.
    self.attachmentBar,
            self.recorder,
            self.buttonBar,
            self.sendButton,
            self.imagePicker,
            self.attachments,
            self.voiceButton,
            self.progressView,
            self.replyToIssue,
            self.countdownView,
            self.issueTransport,
            self.replyTransport,
            self.screenshotButton,
            self.descriptionField,
            self.activityIndicator,
            self.payloadDataSource = nil;

    [super dealloc];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.attachmentBar,
            self.recorder,
            self.buttonBar,
            self.sendButton,
            self.imagePicker,
            self.attachments,
            self.voiceButton,
            self.progressView,
            self.replyToIssue,
            self.countdownView,
            self.issueTransport,
            self.replyTransport,
            self.screenshotButton,
            self.descriptionField,
            self.activityIndicator,
            self.payloadDataSource = nil;
    [super viewDidUnload];
}

@end

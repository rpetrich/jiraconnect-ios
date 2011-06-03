#import "JCOMacros.h"
#import "JCOViewController.h"
#import "UIImage+Resize.h"
#import "Core/UIView+Additions.h"
#import "JCOAttachmentItem.h"
#import "JCOSketchViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface JCOViewController ()
- (void)internalRelease;

- (UIBarButtonItem *)barButtonFor:(NSString *)iconNamed action:(SEL)action;

- (void)addAttachmentItem:(JCOAttachmentItem *)attachment withIcon:(UIImage *)icon action:(SEL)action;

- (BOOL)shouldTrackLocation;

NSArray* toolbarItems; // holds the first 3 system toolbar items.

@property(nonatomic, retain) CLLocation *currentLocation;
@property(nonatomic, retain) CRVActivityView *activityView;
@end

@implementation JCOViewController

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

        // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    sendLocationData = NO;
    if ([self.payloadDataSource respondsToSelector:@selector(locationEnabled)]) {
        sendLocationData = [[self payloadDataSource] locationEnabled];
    }

    if ([self shouldTrackLocation]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];

        //TODO: remove this. just for testing location in the simulator.
#if TARGET_IPHONE_SIMULATOR
        // -33.871088, 151.203665
        CLLocation *fixed = [[CLLocation alloc] initWithLatitude:-33.871088 longitude:151.203665];
        [self setCurrentLocation: fixed];
        [fixed release];
#endif
    }

    // layout views
    self.recorder.recorder.delegate = self;
    self.countdownView.layer.cornerRadius = 7.0;
    
    self.navigationItem.leftBarButtonItem =
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                           target:self
                                                           action:@selector(dismiss)] autorelease];
    self.navigationItem.title = JCOLocalizedString(@"Feedback", "Title of the feedback controller");


    self.navigationItem.rightBarButtonItem =
            [[[UIBarButtonItem alloc] initWithTitle:@"Send"
                                              style:UIBarButtonItemStyleDone
                                             target:self
                                             action:@selector(sendFeedback)] autorelease];

    self.attachments = [NSMutableArray arrayWithCapacity:1];
    self.toolbar.clipsToBounds = YES;
    self.toolbar.items = nil;
    self.toolbar.autoresizesSubviews = YES;

    float descriptionFieldInset = 15;
    self.descriptionField.top = 44 + descriptionFieldInset;
    self.descriptionField.width = self.view.width - (descriptionFieldInset * 2.0);
    descriptionFrame = self.descriptionField.frame;

    self.toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    [self.toolbar setBarStyle:UIBarStyleBlackOpaque];

    UIBarButtonItem *screenshotButton = [self barButtonFor:@"icon_capture.png" action:@selector(addScreenshot)];
    UIBarButtonItem *recordButton = [self barButtonFor:@"icon_record.png" action:@selector(addVoice)];
    UIBarButtonItem *spaceButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil action:nil] autorelease];
    toolbarItems = [[NSArray arrayWithObjects:screenshotButton, recordButton, spaceButton, nil] retain];
    self.toolbar.items = toolbarItems;
    self.descriptionField.inputAccessoryView = self.toolbar;
}

- (void) viewWillAppear:(BOOL)animated {
    [self.descriptionField becomeFirstResponder];
    [_locationManager startUpdatingLocation];
}

- (void) viewDidDisappear:(BOOL)animated {
    [_locationManager stopUpdatingLocation];
}


#pragma mark UITextViewDelegate

- (void)keyboardWillShow:(NSNotification*)notification
{
   /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */

    NSDictionary *userInfo = [notification userInfo];

    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];

    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];

    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y - 40;
    newTextViewFrame.origin.y = 44; // TODO: un-hardcode this

    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];

    self.descriptionField.frame = newTextViewFrame;

    [UIView commitAnimations];

}

- (void)keyboardWillHide:(NSNotification*)notification
{

}

- (UIBarButtonItem *)barButtonFor:(NSString *)iconNamed action:(SEL)action
{
    UIButton *customView = [UIButton buttonWithType:UIButtonTypeCustom];
    [customView addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [customView setBackgroundImage:[UIImage imageNamed:@"button_base.png"] forState:UIControlStateNormal];
    UIImage *icon = [UIImage imageNamed:iconNamed];
    CGRect frame = CGRectMake(0, 0, 40, 30);
    [customView setImage:icon forState:UIControlStateNormal];
    customView.frame = frame;
    UIBarButtonItem *barItem = [[[UIBarButtonItem alloc] initWithCustomView:customView] autorelease];

    return barItem;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    
    return YES;
}

#pragma mark end

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

        // TODO: animate recording ?
//        NSMutableArray *sprites = [NSMutableArray arrayWithCapacity:8];
//        for (int i = 1; i < 9; i++) {
//            NSString *sprintName = [@"icon_record_" stringByAppendingFormat:@"%d.png", i];
//            UIImage *img = [UIImage imageNamed:sprintName];
//            [sprites addObject:img];
//        }
//        self.voiceButton.animationImages = sprites;
//        self.voiceButton.animationDuration = 0.85f;
//
//        [self.voiceButton startAnimating];
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)success
{

    [self hideAudioProgress];

    JCOAttachmentItem *attachment = [[JCOAttachmentItem alloc] initWithName:@"recording"
                                                                       data:[_recorder audioData]
                                                                       type:JCOAttachmentTypeRecording
                                                                contentType:@"audio/x-caf"
                                                             filenameFormat:@"recording-%d.caf"];


    UIImage *newImage = [UIImage imageNamed:@"icon_record_2.png"];
    [self addAttachmentItem:attachment withIcon:newImage action:@selector(voiceAttachmentTapped:)];
    [attachment release];
}

- (void)addAttachmentItem:(JCOAttachmentItem *)attachment withIcon:(UIImage *)icon action:(SEL)action
{
    CGRect buttonFrame = CGRectMake(0, 0, 30, 30);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = buttonFrame;
    
    [button setBackgroundImage:[UIImage imageNamed:@"button_base.png"] forState:UIControlStateNormal];

    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.imageView.layer.cornerRadius = 5.0;

    [button setImage:icon forState:UIControlStateNormal];
    
    UIBarButtonItem *buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    button.tag = [self.toolbar.items count];

    NSMutableArray *buttonItems = [NSMutableArray arrayWithArray:self.toolbar.items];
    [buttonItems addObject:buttonItem];
    [self.toolbar setItems:buttonItems];
    [self.attachments addObject:attachment];
}

- (void)addImageAttachmentItem:(UIImage *)origImg
{
    JCOAttachmentItem *attachment = [[JCOAttachmentItem alloc] initWithName:@"screenshot"
                                                                       data:UIImagePNGRepresentation(origImg)
                                                                       type:JCOAttachmentTypeImage
                                                                contentType:@"image/png"
                                                             filenameFormat:@"screenshot-%d.png"];

    
    UIImage * iconImg =
            [origImg thumbnailImage:30 transparentBorder:0 cornerRadius:0.0 interpolationQuality:kCGInterpolationDefault];
    [self addAttachmentItem:attachment withIcon:iconImg action:@selector(imageAttachmentTapped:)];
    [attachment release];
}

- (void)removeAttachmentItemAtIndex:(NSUInteger)index
{

    NSLog(@"removing attachment: index = %lu count = %lu", index, [self.attachments count]);

    [self.attachments removeObjectAtIndex:index];
    NSMutableArray *buttonItems = [NSMutableArray arrayWithArray:self.toolbar.items];
    [buttonItems removeObjectAtIndex:index + [toolbarItems count]]; // TODO: fix this pullava
    // re-tag all buttons... with their new index. indexed from 2, due to icons...
    for (int i = 0; i < [buttonItems count]; i++) {
        UIBarButtonItem *buttonItem = (UIBarButtonItem *) [buttonItems objectAtIndex:(NSUInteger) i];
        buttonItem.customView.tag = i;
    }

    [self.toolbar setItems:buttonItems animated:YES];
}

- (void)imageAttachmentTapped:(UIButton *)touch
{
    // delete that button, both from the bar, and the images array
    NSUInteger index = (u_int) touch.tag;
    NSUInteger attachmentIndex = index - [toolbarItems count];
    NSLog(@"tapped image index = %lu, count = %lu", index, [self.attachments count]);

    JCOAttachmentItem *attachment = [self.attachments objectAtIndex:attachmentIndex];
    JCOSketchViewController *sketchViewController = [[[JCOSketchViewController alloc] initWithNibName:@"JCOSketchViewController" bundle:nil] autorelease];
    // get the original image, wire it up to the sketch controller
    sketchViewController.image = [[[UIImage alloc] initWithData:attachment.data] autorelease];
    sketchViewController.imageId = [NSNumber numberWithUnsignedInteger:attachmentIndex]; // set this image's id. just the index in the array
    sketchViewController.delegate = self;
    [self presentModalViewController:sketchViewController animated:YES];
    currentAttachmentItemIndex = index;
}

- (void)voiceAttachmentTapped:(UIButton *)touch
{
    // delete that button, both from the bar, and the images array
    NSUInteger index = (u_int) touch.tag;
    NSUInteger attachmentIndex = index - [toolbarItems count]; // TODO: refactor this, and the image method too, into a rebase method..
    NSLog(@"tapped voice attachmentIndex index = %lu, count = %lu", attachmentIndex, [self.attachments count]);
    
    JCOAttachmentItem *attachment = [self.attachments objectAtIndex:attachmentIndex];

    UIAlertView *view =
            [[UIAlertView alloc] initWithTitle:JCOLocalizedString(@"RemoveRecording", @"Remove recording title") message:JCOLocalizedString(@"AlertBeforeDeletingRecording", @"Warning message before deleting a recording.") delegate:self
                             cancelButtonTitle:JCOLocalizedString(@"No", @"") otherButtonTitles:JCOLocalizedString(@"Yes", @""), nil];
    currentAttachmentItemIndex = attachmentIndex;
    [view show];
    [view release];


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

    UIImage *origImg = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];

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
    UIImage * iconImg =
            [image thumbnailImage:30 transparentBorder:0 cornerRadius:0.0 interpolationQuality:kCGInterpolationDefault];

    UIBarButtonItem *item = [self.toolbar.items objectAtIndex:index + [toolbarItems count]];
    ((UIButton *) item.customView).imageView.image = iconImg;
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

- (IBAction)sendFeedback
{
	CGPoint center = CGPointMake(self.descriptionField.width/2.0, self.descriptionField.height/2.0 + 50);
    //TODO: uncomment this for production...
//    CRVActivityView *av = [CRVActivityView newDefaultViewForParentView:[self view] center:center];
//    [av setText:JCOLocalizedString(@"Sending...", @"")];
//    [av startAnimating];
//    [av setDelegate:self];
//    [self setActivityView:av];
//    [av release];

    self.issueTransport.delegate = self;
    NSDictionary *payloadData = nil;
    NSMutableDictionary *customFields = [[NSMutableDictionary alloc] init];

    if ([self.payloadDataSource respondsToSelector:@selector(payload)]) {
        payloadData = [[self.payloadDataSource payload] retain];
    }
    if ([self.payloadDataSource respondsToSelector:@selector(customFields)]) {
        [customFields addEntriesFromDictionary:[self.payloadDataSource customFields]];
    }


    if ([self shouldTrackLocation] && [self currentLocation]) {
        NSMutableArray *objects = [NSMutableArray arrayWithCapacity:3];
        NSMutableArray *keys =    [NSMutableArray arrayWithCapacity:3];
        @synchronized (self) {
            NSNumber *lat = [NSNumber numberWithDouble:currentLocation.coordinate.latitude];
            NSNumber *lng = [NSNumber numberWithDouble:currentLocation.coordinate.longitude];
            NSString *locationString = [NSString stringWithFormat:@"%f,%f", lat.doubleValue, lng.doubleValue];
            [keys addObject:@"lat"];      [objects addObject:lat];
            [keys addObject:@"lng"];      [objects addObject:lng];
            [keys addObject:@"location"]; [objects addObject:locationString];
        }
        // Merge the location into the existing customFields.
        NSDictionary *dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        [customFields addEntriesFromDictionary:dict];
        [dict release];
    }

    if (self.replyToIssue) {
        [self.replyTransport sendReply:self.replyToIssue
                           description:self.descriptionField.text
                                images:self.attachments
                               payload:payloadData
                                fields:customFields];
    } else {
        // use the first 100 chars of the description as the issue titlle
        NSString *description = self.descriptionField.text;
        u_int length = 80;
        u_int toIndex = [description length] > length ? length : [description length];
        NSString *truncationMarker = [description length] > length ? @"..." : @"";
        [self.issueTransport send:[[description substringToIndex:toIndex] stringByAppendingString:truncationMarker]
                      description:self.descriptionField.text
                           images:self.attachments
                          payload:payloadData
                           fields:customFields];
    }

    [payloadData release];
    [customFields release];
}

-(void) dismissActivity
{
    [[self activityView] stopAnimating];
}

- (void)transportDidFinish
{
    [self dismissActivity];
    [self dismissModalViewControllerAnimated:YES];

    self.descriptionField.text = @"";
    [self.attachments removeAllObjects];
    [self.toolbar setItems:toolbarItems];
}

- (void)transportDidFinishWithError:(NSError *)error
{
    [self dismissActivity];
}

#pragma mark end

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//    return YES;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    @synchronized (self) {
        [self setCurrentLocation:newLocation];
    }
}


#pragma mark -
#pragma mark CRVActivityViewDelegate
- (void)userDidCancelActivity
{
    [[self issueTransport] cancel];
}

#pragma mark -
#pragma mark Private Methods
- (BOOL)shouldTrackLocation {
    return sendLocationData && [CLLocationManager locationServicesEnabled];
}

#pragma mark -
#pragma mark Memory Managment

@synthesize descriptionField, countdownView, progressView, imagePicker, currentLocation, activityView;

@synthesize issueTransport = _issueTransport, replyTransport = _replyTransport, payloadDataSource = _payloadDataSource, attachments = _attachments, recorder = _recorder, replyToIssue = _replyToIssue;
@synthesize toolbar;
@synthesize voiceButton = _voiceButton;


- (void)dealloc
{
    // Release any retained subviews of the main view.
    [self internalRelease];
    [super dealloc];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self internalRelease];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}

- (void)internalRelease
{
    [_locationManager release];
    [_voiceButton release];
    [toolbarItems release];
    self.toolbar = nil;
    self.recorder = nil;
    self.imagePicker = nil;
    self.attachments = nil;
    self.progressView = nil;
    self.replyToIssue = nil;
    self.countdownView = nil;
    self.issueTransport = nil;
    self.replyTransport = nil;
    self.descriptionField = nil;
    self.payloadDataSource = nil;
    self.currentLocation = nil;
    self.activityView = nil;
}

@end

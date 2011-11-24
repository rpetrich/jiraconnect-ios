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
#import "JMC.h"
#import "JMCMacros.h"
#import "JMCViewController.h"
#import "UIImage+JMCResize.h"
#import "UIView+JMCAdditions.h"
#import "JMCAttachmentItem.h"
#import "JMCSketchViewController.h"
#import "JMCIssueStore.h"
#import "JMCToolbarButton.h"
#import <QuartzCore/QuartzCore.h>
#import "JMCCreateIssueDelegate.h"
#import "JMCReplyDelegate.h"
#import "JMCTransport.h"

@interface JMCViewController ()

- (BOOL)shouldTrackLocation;

- (UIBarButtonItem *)barButtonFor:(NSString *)iconNamed action:(SEL)action;
- (UIButton *)buttonFor:(NSString *)iconNamed action:(SEL)action;

- (void)addAttachmentItem:(JMCAttachmentItem *)attachment withIcon:(UIImage *)icon action:(SEL)action;
- (void)addButtonsToView;
- (void)addImageAttachmentItem:(UIImage *)origImg;
- (void)dismissKeyboard;
- (void)internalRelease;
- (void)hideAudioProgress;
- (void)removeAttachmentItemAtIndex:(NSUInteger)attachmentIndex;

@property(nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic, retain) CLLocation *currentLocation;
@property(nonatomic, retain) UIPopoverController *popover;
@property(nonatomic, retain) UIButton *screenshotButton;

@end

@implementation JMCViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

    if ([self shouldTrackLocation]) {
        CLLocationManager* locMgr = [[CLLocationManager alloc] init];
        self.locationManager = locMgr;
        [locMgr release];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        

        //TODO: remove this. just for testing location in the simulator.
#if TARGET_IPHONE_SIMULATOR
        // -33.871088, 151.203665
        CLLocation *fixed = [[CLLocation alloc] initWithLatitude:-33.871088 longitude:151.203665];
        
        [self setCurrentLocation: fixed];
        [fixed release];
#endif
    }

    // layout views
    self.countdownView.layer.cornerRadius = 7.0;
    
    if (self.replyToIssue) {
        self.navigationItem.title = JMCLocalizedString(@"Reply", "Title of the feedback controller");
    }
    else {
        self.navigationItem.title = JMCLocalizedString(@"Feedback", "Title of the feedback controller");
    }


    self.navigationItem.rightBarButtonItem =
            [[[UIBarButtonItem alloc] initWithTitle:JMCLocalizedString(@"Send", @"Send feedback")
                                              style:UIBarButtonItemStyleDone
                                             target:self
                                             action:@selector(sendFeedback)] autorelease];


    self.attachments = [NSMutableArray arrayWithCapacity:1];

    [self addButtonsToView];

    // TODO: the transport class should be split in 2. 1 for actually sending, the other for creating the request
    _issueTransport = [[JMCIssueTransport alloc] init];
    _replyTransport = [[JMCReplyTransport alloc] init];
    
    JMCCreateIssueDelegate* createDelegate = [[JMCCreateIssueDelegate alloc] init];
    _issueTransport.delegate = createDelegate;
    [createDelegate release];
    
    JMCReplyDelegate* replyDelegate = [[JMCReplyDelegate alloc] init];
    _replyTransport.delegate = replyDelegate;
    [replyDelegate release];

}

- (void) viewWillAppear:(BOOL)animated {
    [self.locationManager startUpdatingLocation];
    
    // Show cancel button only if this is the first controller on the stack
    if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
        self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:JMCLocalizedString(@"Cancel", @"Cancel feedback")
                                          style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(dismiss)] autorelease];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self.descriptionField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self dismissKeyboard];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) ||
            UIInterfaceOrientationIsPortrait(interfaceOrientation));
    //    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // Hide the popover if visible, dealloc otherwise
    if (self.popover.popoverVisible) {
        [self.popover dismissPopoverAnimated:NO];
    }
    else {
        self.popover = nil;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // If popover is set, then present it from button
    if (self.popover) {
        [self.popover presentPopoverFromRect:self.screenshotButton.frame
                                      inView:self.screenshotButton.superview 
                    permittedArrowDirections:UIPopoverArrowDirectionAny 
                                    animated:YES];
    }
}

#pragma mark - UIKeyboard Notification Methods

/*
 Reduce the size of the view so that it's not obscured by the keyboard.
 Animate the resize so that it's in sync with the appearance of the keyboard.
 */
- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Get the origin of the keyboard when it's displayed.
        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];

        // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system.
        // The bottom of the text view's frame should align with the top of the keyboard's final position.
        CGRect keyboardRect = [aValue CGRectValue];

        CGRect newFrame = self.view.bounds;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            newFrame.size.height -= keyboardRect.size.height;
        }
        else {
            newFrame.size.height -= keyboardRect.size.width;
        }

        self.view.frame = newFrame;
        self.countdownView.center = self.descriptionField.center;
    }
    else {
        CGRect newFrame = self.view.bounds;
        newFrame.size.height /= 2;

        self.descriptionField.frame = newFrame;
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Get the origin of the keyboard when it's displayed.
        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        
        // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system.
        // The bottom of the text view's frame should align with the top of the keyboard's final position.
        CGRect keyboardRect = [aValue CGRectValue];
        
        CGRect newFrame = self.view.bounds;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            newFrame.size.height += keyboardRect.size.height;
        }
        else {
            newFrame.size.height += keyboardRect.size.width;
        }
        
        self.view.frame = newFrame;
        self.countdownView.center = self.descriptionField.center;
    }
    else {
        self.descriptionField.frame = self.view.bounds;
    }
    
    [UIView commitAnimations];
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    // If keyboard did hide and popover is visible, present it from new position
    if (self.popover.popoverVisible) {
        [self.popover presentPopoverFromRect:self.screenshotButton.frame
                                      inView:self.screenshotButton.superview 
                    permittedArrowDirections:UIPopoverArrowDirectionAny 
                                    animated:YES];
    }
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView 
{
    return YES;
}

#pragma mark - UIControl Action Methods

- (IBAction)dismiss
{
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)addScreenshot
{
    if ([self.popover isPopoverVisible]) 
    {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    } 
    else 
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        {
            self.popover = [[[UIPopoverController alloc] initWithContentViewController:imagePicker] autorelease];
            [self.popover presentPopoverFromRect:self.screenshotButton.frame
                                          inView:self.screenshotButton.superview 
                        permittedArrowDirections:UIPopoverArrowDirectionAny 
                                        animated:YES];
        }
        else 
        {
            [self presentModalViewController:imagePicker animated:YES];
        }
        [imagePicker release];
    }
       
}

- (IBAction)addVoice
{
    JMCRecorder* recorder = [JMCRecorder instance];
    if (!recorder) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: JMCLocalizedString(@"Voice Recording", @"Alert title when no audio") 
                                   message: JMCLocalizedString(@"JMCVoiceRecordingNotSupported", @"Alert when no audio") 
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    recorder.recorder.delegate = self;
    if (recorder.recorder.recording) {
        [recorder stop];

    } else {
        [recorder start];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
        self.progressView.progress = 0;

        self.countdownView.hidden = NO;

        // start animating the voice button...
        NSMutableArray *sprites = [NSMutableArray arrayWithCapacity:8];
        for (int i = 1; i < 9; i++) {
            NSString *sprintName = [@"icon_record_" stringByAppendingFormat:@"%d", i];
            UIImage *img = [UIImage imageNamed:sprintName];
            [sprites addObject:img];
        }
        self.voiceButton.imageView.animationImages = sprites;
        self.voiceButton.imageView.animationDuration = 0.85f;
        [self.voiceButton.imageView startAnimating];

    }
}

- (void)imageAttachmentTapped:(UIButton *)touch
{
    NSUInteger touchIndex = (u_int) touch.tag;
    NSUInteger attachmentIndex = touchIndex;
    JMCAttachmentItem *attachment = [self.attachments objectAtIndex:attachmentIndex];
    JMCSketchViewController *sketchViewController = [[[JMCSketchViewController alloc] initWithNibName:@"JMCSketchViewController" bundle:nil] autorelease];
    // get the original image, wire it up to the sketch controller
    sketchViewController.image = [[[UIImage alloc] initWithData:attachment.data] autorelease];
    sketchViewController.imageId = [NSNumber numberWithUnsignedInteger:attachmentIndex]; // set this image's id. just the index in the array
    sketchViewController.delegate = self;
    [self presentModalViewController:sketchViewController animated:YES];
    currentAttachmentItemIndex = touchIndex;
}

- (void)voiceAttachmentTapped:(UIButton *)touch
{
    // delete that button, both from the bar, and the images array
    NSUInteger tapIndex = (u_int) touch.tag;
    NSUInteger attachmentIndex = tapIndex;
    UIAlertView *view =
            [[UIAlertView alloc] initWithTitle:JMCLocalizedString(@"RemoveRecording", @"Remove recording title")
                                 message:JMCLocalizedString(@"AlertBeforeDeletingRecording", @"Warning message before deleting a recording.")
                                 delegate:self
                             cancelButtonTitle:JMCLocalizedString(@"No", @"")
                             otherButtonTitles:JMCLocalizedString(@"Yes", @""), nil];
    currentAttachmentItemIndex = attachmentIndex;
    [view show];
    [view release];


}

- (IBAction)sendFeedback
{
    
    if ([self.descriptionField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 0
        && self.attachments.count <= 0) {
        // No data entered, just return.
        return;
    }
    NSMutableDictionary *customFields = [[JMC instance] getCustomFields];
    NSMutableArray* allAttachments = [NSMutableArray arrayWithArray:self.attachments];
    
    
    if ([[JMC instance].customDataSource respondsToSelector:@selector(customAttachment)]) {
        JMCAttachmentItem *payloadData = [[JMC instance].customDataSource customAttachment];
        if (payloadData) {
            [allAttachments addObject:payloadData];
        }
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
    
    // add all custom fields as one attachment item
    NSData *customFieldsJSON = [[JMCTransport buildJSONString:customFields] dataUsingEncoding:NSUTF8StringEncoding];
    
    JMCAttachmentItem *customFieldsItem = [[JMCAttachmentItem alloc] initWithName:@"customfields"
                                                                             data:customFieldsJSON
                                                                             type:JMCAttachmentTypeCustom
                                                                      contentType:@"application/json"
                                                                   filenameFormat:@"customfields.json"];
    [allAttachments addObject:customFieldsItem];
    [customFieldsItem release];
    
    
    if (self.replyToIssue) {
        [self.replyTransport sendReply:self.replyToIssue
                           description:self.descriptionField.text
                           attachments:allAttachments];
    } else {
        // use the first 80 chars of the description as the issue summary
        NSString *description = self.descriptionField.text;
        u_int length = 80;
        u_int toIndex = [description length] > length ? length : [description length];
        NSString *truncationMarker = [description length] > length ? @"..." : @"";
        [self.issueTransport send:[[description substringToIndex:toIndex] stringByAppendingString:truncationMarker]
                      description:self.descriptionField.text
                      attachments:allAttachments];
    }
    
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissModalViewControllerAnimated:YES];
    }
    
    self.descriptionField.text = @"";
    [self.attachments removeAllObjects];
    [self.toolbar setItems:systemToolbarItems];
}

#pragma mark - AVAudioRecorderDelegate Methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)avRecorder successfully:(BOOL)success
{
    [self hideAudioProgress];
    
    JMCRecorder* recorder = [JMCRecorder instance];
    // FIXME: This leads to potential crashes as it loads the audio file into memory 
    // regardless of its size and how many attachments were already added
    JMCAttachmentItem *attachment = [[JMCAttachmentItem alloc] initWithName:@"recording"
                                                                       data:[recorder audioData]
                                                                       type:JMCAttachmentTypeRecording
                                                                contentType:@"audio/aac"
                                                             filenameFormat:@"recording-%d.aac"];
    
    
    UIImage *newImage = [UIImage imageNamed:@"icon_record_2"];
    [self addAttachmentItem:attachment withIcon:newImage action:@selector(voiceAttachmentTapped:)];
    [attachment release];
    [recorder cleanUp];
}

#pragma mark - UIAlertViewDelelgate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // dismiss modal dialog.
    if (buttonIndex == 1) {
        [self removeAttachmentItemAtIndex:currentAttachmentItemIndex];
    }
    currentAttachmentItemIndex = 0;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    if ([self.popover isPopoverVisible]) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }

    UIImage *origImg = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (origImg.size.height > screenSize.height) {

        // resize image... its too huge! (only meant to be screenshots, not photos..)
        CGSize size = origImg.size;
        float ratio = screenSize.height / size.height;
        CGSize smallerSize = CGSizeMake(ratio * size.width, ratio * size.height);
        origImg = [origImg jmc_resizedImage:smallerSize interpolationQuality:kCGInterpolationMedium];
    }

    [self addImageAttachmentItem:origImg];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - JMCSketchViewControllerDelegate

- (void)sketchController:(UIViewController *)controller didFinishSketchingImage:(UIImage *)image withId:(NSNumber *)imageId
{
    [self dismissModalViewControllerAnimated:YES];
    NSUInteger imgIndex = [imageId unsignedIntegerValue];
    JMCAttachmentItem *attachment = [self.attachments objectAtIndex:imgIndex];
    attachment.data = UIImagePNGRepresentation(image);

    // also update the icon in the toolbar
    UIImage * iconImg =
            [image jmc_thumbnailImage:30 transparentBorder:0 cornerRadius:0.0 interpolationQuality:kCGInterpolationDefault];

    UIBarButtonItem *item = [self.toolbar.items objectAtIndex:imgIndex];
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

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    @synchronized (self) {
        [self setCurrentLocation:newLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    JMCDLog(@"Location failed with error: %@", [error localizedDescription]);
}

#pragma mark - Private Helper Methods

- (void)addButtonsToView {
    float offset = 5;
    if ([[JMC instance] isPhotosEnabled]) {
        self.screenshotButton = [self buttonFor:@"icon_capture" action:@selector(addScreenshot)];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.screenshotButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
            self.screenshotButton.frame = CGRectMake(self.descriptionField.frame.size.width - 44.0 - offset, 
                                                     self.view.frame.size.height - 44.0, 
                                                     44.0, 
                                                     44.0);
        }
        else {
            self.screenshotButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            self.screenshotButton.frame = CGRectMake(self.descriptionField.frame.size.width - 50.0, 
                                                     0 + offset, 
                                                     44.0, 
                                                     44.0);
        }
        [self.view addSubview:self.screenshotButton]; 
        
        offset += 50;
    }
    
    if ([[JMC instance] isVoiceEnabled]) {
        self.voiceButton = [self buttonFor:@"icon_record" action:@selector(addVoice)];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.voiceButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
            self.voiceButton.frame = CGRectMake(self.descriptionField.frame.size.width - 44.0 - offset, 
                                                self.view.frame.size.height - 44.0, 
                                                44.0, 
                                                44.0);
        }
        else {
            self.voiceButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            self.voiceButton.frame = CGRectMake(self.descriptionField.frame.size.width - 50.0, 
                                                0 + offset, 
                                                44.0, 
                                                44.0);
        }
        [self.view addSubview:self.voiceButton]; 
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.descriptionField.jmc_height -= 50.0;
    }
    else {
        self.descriptionField.jmc_width -= 50.0;
    }
}

- (UIButton *)buttonFor:(NSString *)iconNamed action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:iconNamed] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 44, 44);
    return button;
}

- (UIBarButtonItem *)barButtonFor:(NSString *)iconNamed action:(SEL)action
{
    UIButton *customView = [JMCToolbarButton buttonWithType:UIButtonTypeCustom];
    [customView addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [customView setBackgroundImage:[UIImage imageNamed:@"button_base"] forState:UIControlStateNormal];
    UIImage *icon = [UIImage imageNamed:iconNamed];
    CGRect frame = CGRectMake(0, 0, 41, 31);
    [customView setImage:icon forState:UIControlStateNormal];
    customView.frame = frame;
    
    UIBarButtonItem *barItem = [[[UIBarButtonItem alloc] initWithCustomView:customView] autorelease];
    
    return barItem;
}

- (BOOL)shouldTrackLocation {
    return [[JMC instance] isLocationEnabled] && [CLLocationManager locationServicesEnabled];
}

- (void)dismissKeyboard
{
    [self.descriptionField resignFirstResponder];
}

- (void)updateProgress:(NSTimer *)theTimer
{
    JMCRecorder* recorder = [JMCRecorder instance];
    float currentDuration = [recorder currentDuration];
    float progress = (currentDuration / recorder.recordTime);
    self.progressView.progress = progress;
}

- (void)hideAudioProgress
{
    self.countdownView.hidden = YES;
    self.progressView.progress = 0;
    [self.voiceButton.imageView stopAnimating];
    self.voiceButton.imageView.animationImages = nil;
    [_timer invalidate];
}

-(void)reindexAllItems:(NSArray*)buttonItems
{
    // re-tag all buttons... with their new index.
    for (NSUInteger i = 0; i < [buttonItems count]; i++) {
        UIBarButtonItem *item = (UIBarButtonItem *) [buttonItems objectAtIndex:(NSUInteger) i];
        item.customView.tag = i;
    }
    [self.toolbar setItems:buttonItems animated:YES];
}

- (void)addAttachmentItem:(JMCAttachmentItem *)attachment withIcon:(UIImage *)icon action:(SEL)action
{
    CGRect buttonFrame = CGRectMake(0, 0, 30, 30);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = buttonFrame;
    
    [button setBackgroundImage:[UIImage imageNamed:@"button_base"] forState:UIControlStateNormal];
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.imageView.layer.cornerRadius = 5.0;
    
    [button setImage:icon forState:UIControlStateNormal];
    
    UIBarButtonItem *buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    
    // FIXME: Limit number of items so that they don't overlap with the default buttons
    // or add a "more" item if more than 3 items exist
    NSMutableArray *buttonItems = [NSMutableArray arrayWithArray:self.toolbar.items];
    [buttonItems insertObject:buttonItem atIndex:0];
    [self.attachments insertObject:attachment atIndex:0]; // attachments must be kept in sycnh with buttons
    [self reindexAllItems:buttonItems];
}

- (void)addImageAttachmentItem:(UIImage *)origImg
{
    JMCAttachmentItem *attachment = [[JMCAttachmentItem alloc] initWithName:@"screenshot"
                                                                       data:UIImagePNGRepresentation(origImg)
                                                                       type:JMCAttachmentTypeImage
                                                                contentType:@"image/png"
                                                             filenameFormat:@"screenshot-%d.png"];
    
    
    UIImage * iconImg =
    [origImg jmc_thumbnailImage:30 transparentBorder:0 cornerRadius:0.0 interpolationQuality:kCGInterpolationDefault];
    [self addAttachmentItem:attachment withIcon:iconImg action:@selector(imageAttachmentTapped:)];
    [attachment release];
}

- (void)removeAttachmentItemAtIndex:(NSUInteger)attachmentIndex
{
    NSMutableArray *buttonItems = [NSMutableArray arrayWithArray:self.toolbar.items];
    [self.attachments removeObjectAtIndex:attachmentIndex];
    [buttonItems removeObjectAtIndex:attachmentIndex];
    [self reindexAllItems:buttonItems];
}

#pragma mark - Memory Managment Methods

@synthesize descriptionField, countdownView, progressView, currentLocation, locationManager = _locationManager, popover;

@synthesize issueTransport = _issueTransport, replyTransport = _replyTransport, attachments = _attachments, replyToIssue = _replyToIssue;
@synthesize toolbar;
@synthesize voiceButton = _voiceButton, screenshotButton = _screenshotButton;

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
}

- (void)internalRelease
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    [systemToolbarItems release], systemToolbarItems = nil;
    
    self.voiceButton = nil;
    self.screenshotButton = nil;
    self.toolbar = nil;
    self.attachments = nil;
    self.progressView = nil;
    self.replyToIssue = nil;
    self.countdownView = nil;
    self.descriptionField = nil;
    self.currentLocation = nil;
    self.replyTransport = nil;
    self.issueTransport = nil;
    self.popover = nil;
}

@end

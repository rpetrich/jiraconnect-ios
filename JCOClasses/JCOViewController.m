//
//  JCCreateViewController.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//

#import "JCOViewController.h"
#import "JCO.h"
#import "JSON.h"
#import "JCORecorder.h"
#import "JCOPayloadDataSource.h"

@interface JCOViewController()

-(void) setVoiceButtonTitleWithDuration:(float)duration;

@end

@implementation JCOViewController

UIImage* _image;
JCORecorder* _recorder;
NSTimer* _timer;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.transport = [[JCOTransport alloc] init];
	_recorder = [[[JCORecorder alloc] init] retain]; 
	_recorder.recorder.delegate = self;
	self.countdownView.layer.cornerRadius = 7.0;

    NSLog(@"View Did load!! %@", self);
}

- (void) viewDidAppear:(BOOL)animated {
    [self setVoiceButtonTitleWithDuration:[_recorder previousDuration]];

}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
	self.voiceButton, 
	self.sendButton, 
	self.screenshotButton, 
	self.descriptionField, 
	self.descriptionField, 
	self.countdownView,
	self.progressView,
	self.imagePicker = nil;
	[_transport release]; _transport = nil;
	[_recorder release]; _recorder = nil;
    [super viewDidUnload];
    NSLog(@"View Did UNload!!");
}

- (IBAction) dismiss {
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction) addScreenshot {
	[self presentModalViewController:imagePicker animated:YES];
}

-(void) setVoiceButtonTitleWithDuration:(float)duration {

	NSString* durationStr = [NSString stringWithFormat:@"%.2f\"", duration];
	[self.voiceButton  setTitle:durationStr forState:UIControlStateNormal];
	[self.voiceButton  setTitle:durationStr forState:UIControlStateSelected];
	[self.voiceButton  setTitle:durationStr forState:UIControlStateHighlighted];
}

-(void) updateProgress:(NSTimer*)theTimer {
    float currentDuration = [_recorder currentDuration];
	float progress = (currentDuration/_recorder.recordTime);
	self.progressView.progress = progress;	
	[self setVoiceButtonTitleWithDuration:currentDuration];
}

-(void) hideAudioProgress {
	self.countdownView.hidden = YES; 
	self.progressView.progress = 0;
	[self.voiceButton setBackgroundImage:[UIImage imageNamed:@"button_Record.png"] forState:UIControlStateNormal];
	[_timer invalidate];
}

- (IBAction) addVoice {
	
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


-(void) audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)success {
	[self setVoiceButtonTitleWithDuration:[_recorder previousDuration]];
	[self hideAudioProgress];
	
}

- (IBAction) sendFeedback {

	self.transport.delegate = self;
    NSDictionary * payloadData = [self.payloadDataSource payloadFor:self.subjectField.text];
    NSLog(@"Payload: %@", payloadData);
    [self.transport send:self.subjectField.text description:self.descriptionField.text screenshot:_image andVoiceData:[_recorder audioData]];
	
}

-(void) transportDidFinish {

	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage* origImg = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
	[self dismissModalViewControllerAnimated:YES];
	[self.screenshotButton setBackgroundImage:origImg forState:UIControlStateNormal];
	[self.screenshotButton setTitle:nil forState:UIControlStateNormal];
	_image = origImg;
	[_image retain];
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
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
	
	if([text isEqualToString:@"\n"]) {
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
@synthesize transport=_transport, payloadDataSource=_payloadDataSource;

- (void)dealloc {
	[_image release];_image = nil;
    [_recorder release];_recorder = nil;
    self.transport,
    self.sendButton,
    self.imagePicker,
    self.voiceButton,
    self.progressView,
    self.subjectField,
    self.countdownView,
    self.screenshotButton,
    self.descriptionField,
    self.payloadDataSource = nil;
    [super dealloc];
}


@end

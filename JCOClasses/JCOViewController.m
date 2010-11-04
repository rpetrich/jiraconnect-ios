//
//  JCCreateViewController.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCOViewController.h"
#import "JCO.h"
#import "JSON.h"
#import "JCORecorder.h"


@implementation JCOViewController

UIImage* _image;
JCORecorder* _recorder;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.transport = [[JCOTransport alloc] init];
	_recorder = [[JCORecorder initialize] retain];
		
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.voiceButton, 
	self.sendButton, 
	self.screenshotButton, 
	self.descriptionField, 
	self.descriptionField, 
	self.imagePicker = nil;
	[_transport release]; _transport = nil;
	[_recorder release]; _recorder = nil;
	
}

- (IBAction) dismiss {
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction) addScreenshot {
	NSLog(@"add screenshot...%@", 	[screenshotButton.imageView image]);
	[self presentModalViewController:imagePicker animated:YES];
}

- (IBAction) addVoice {
	
	NSLog(@"addVoice: Is recording? %d - %@", _recorder.recorder.recording, _recorder.recorder);
	
	if (_recorder.recorder.recording) {
		NSData* voiceData = [_recorder stop];
		NSLog(@"Reorded voice: %@", _recorder.recorder.url );
	} else {
		NSLog(@"adding voice...%@", @"voice data");
		[_recorder start];
		NSLog(@"Is recording? %d", _recorder.recorder.recording);
	}


}


- (IBAction) sendFeedback {

	self.transport.delegate = self;
	NSLog(@"Sending feedback...%@, %@, %@", [screenshotButton currentBackgroundImage], self.subjectField.text, self.descriptionField.text);
	[self.transport send:self.subjectField.text description:self.descriptionField.text screenshot:_image andVoiceData:nil]; //TODO get voice data
	
}

-(void) transportDidFinish {

	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"Picked Media: %@", info);
	UIImage* origImg = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
	[self dismissModalViewControllerAnimated:YES];
	[screenshotButton setBackgroundImage:origImg forState:UIControlStateNormal];
	_image = origImg;
	[_image retain];
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	NSLog(@"Picker Cancelled");
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


@synthesize sendButton, voiceButton, screenshotButton, descriptionField, subjectField, imagePicker;
@synthesize transport=_transport;

- (void)dealloc {
    [super dealloc];
	[_image release];_image = nil;
	[_transport release];_transport = nil;
}


@end

//
//  JCCreateViewController.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//  Copyright 2010 Nick Pellow. All rights reserved.
//

#import "JCCreateViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JCSetup.h"
#import "SpeakHereViewController.h"

@implementation JCCreateViewController

UIImage* _image;
NSString* _imageName;
SpeakHereViewController* _speakController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


-(IBAction) addScreenshot {
	NSLog(@"add screenshot...%@", 	[screenshotButton.imageView image]);
	[self presentModalViewController:imagePicker animated:YES];
}

- (IBAction) addVoice {
	NSLog(@"add voice...%@", @"voice data");
	_speakController = [[[SpeakHereViewController alloc] initWithNibName:@"SpeakHereViewController" bundle:nil] autorelease];
	[self presentModalViewController:_speakController animated:YES];
}


#pragma mark ASIHTTPRequest

- (IBAction) sendFeedback {
	NSLog(@"Sending feedback...%@, %@, %@", [screenshotButton currentBackgroundImage], self.subjectField.text, self.descriptionField.text);

	NSString* recordFile = _speakController.recordFile;
	NSLog(@"RECORD FILE %@", recordFile);


	// issue creation url is:
	// curl -u admin:admin -F media=@image.png "http://localhost:2990/jira/rest/reallife/1.0/jirarl/upload?location=blah&pid=10000&issuetype=1&summary=testing123&reporter=admin"
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:subjectField.text forKey:@"subject"];
	[params setObject:descriptionField.text forKey:@"description"];
	NSDictionary* metaData = [[JCSetup instance] getMetaData];
	[params addEntriesFromDictionary:metaData];

	
	NSLog(@"App Data is :%@", params);
	
	NSURL* url = [NSURL URLWithString:@"rest/jconnect/latest/issue" relativeToURL:[JCSetup instance].url];

	NSLog(@"About to send: %@ to: %@", params, url);

	[self.activityIndicator startAnimating];
	
	ASIFormDataRequest* upRequest = [ASIFormDataRequest requestWithURL:url];
	
	if (_image != nil) // take a screenshot of the movie to upload as well.
	{
		NSData* imgData = UIImagePNGRepresentation(_image);	
		[upRequest setData:imgData withFileName:_imageName andContentType:@"image/png" forKey:@"image"];
		
	}
	
	if (recordFile != nil) // also attach a recording
	{
		NSData* imgData = [NSData dataWithContentsOfFile:recordFile];
		[upRequest setData:imgData withFileName:@"voice-feedback.caf" andContentType:@"audio/x-caf" forKey:@"recording"];
	}
	
//	NSLog(@"POST DATA: \n%@", );
	
	[upRequest setDelegate:self];
	[upRequest setTimeOutSeconds:15];
	[upRequest startAsynchronous];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
	
	NSLog(@"Response: %@", [request responseString]);
	NSLog(@"Headers: %@	", [	request responseHeaders]);
	NSString* location = [[request responseHeaders] objectForKey:@"Location"];
	NSLog(@"LOCATION: %@", location);
	NSArray *components = [location	componentsSeparatedByString:@"/"];
	NSString* issueKey = [components lastObject];
	NSLog(@"Got issue key: %@", issueKey);
	[activityIndicator stopAnimating];
	[self dismissModalViewControllerAnimated:YES];

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	
	[self.activityIndicator stopAnimating];
	
	NSString* msg = [NSString stringWithFormat:@"You need an Internet Connection to use this app. \n %@, \n URL: %@ \n status code: %d", 
					 [error localizedDescription], [request url], [request  responseStatusCode] ];
	NSLog(@"requestFailed: %@", msg);
	UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"Error uploading data to server"
														 message:msg
														delegate:nil
											   cancelButtonTitle:@"Ok"
											   otherButtonTitles:nil];
	[alertView2 show];
	[alertView2 release];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark end


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"Picked Media: %@", info);
	UIImage* origImg = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
	[self dismissModalViewControllerAnimated:YES];
	[screenshotButton setBackgroundImage:origImg forState:UIControlStateNormal];
	_image = origImg;
	_imageName = @"TEST.png";
	[_imageName retain];
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
	NSLog(@"Did end editing..");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSLog(@"should change text in range...");
	
	if([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		return NO;
	}
	return YES;
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@synthesize sendButton, voiceButton, screenshotButton, descriptionField, subjectField, imagePicker,activityIndicator;

- (void)dealloc {
    [super dealloc];
	[_image release];
	[_imageName release];
}


@end

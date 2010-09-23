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

@implementation JCCreateViewController



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
}


#pragma mark ASIHTTPRequest

- (IBAction) sendFeedback {
	NSLog(@"Sending feedback...%@, %@, %@", [screenshotButton currentBackgroundImage], self.subjectField.text, self.descriptionField.text);
    // issue creation url is:
	// curl -u admin:admin -F media=@image.png "http://localhost:2990/jira/rest/reallife/1.0/jirarl/upload?location=blah&pid=10000&issuetype=1&summary=testing123&reporter=admin"
	
	NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:subjectField.text forKey:@"subject"];
	[params setObject:descriptionField.text forKey:@"description"];
	[params setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"udid"]; // TODO configure

	
//	NSLog(@"img title %@, title:%@", imgName, title);
//	if (title == nil || [title isEqual:@""]) title = imgName;
//	
//	[params setObject:title forKey:@"summary"];		
//	[params setObject:udid forKey:@"clientid"]; // TODO: store this in a custom field?
//	
//	if (currentLocation != nil)
//	{
//		CLLocationCoordinate2D coord = self.currentLocation.coordinate;
//		NSString* location = [NSString stringWithFormat:@"%f,%f", coord.latitude, coord.longitude];
//		NSLog(@"LOCATION: %@", location);
//		[params setObject:[NSString stringWithFormat:@"%f", coord.latitude] forKey:@"lat"]; // TODO: store this in a custom field in JIRA.
//		[params setObject:[NSString stringWithFormat:@"%f", coord.longitude] forKey:@"lng"]; // TODO: store this in a custom field in JIRA.
//	}
//	
//	[params setObject:@"admin" forKey:@"os_username"]; // TODO configure, remove from url
//	[params setObject:@"admin" forKey:@"os_password"]; // TODO configure, remove from url
//	
//	NSString *parameters = [Utils encodeParameters:params];
//	NSString *urlStr = [NSString stringWithFormat:@"%@/%@", BASE_URL, @"rest/reallife/1.0/jirarl/upload"]; // TODO configure
//	
//	NSString *url = [NSString stringWithFormat:@"%@?%@", urlStr, parameters];			
//	// get the image data:
//	
//	
//	
//	NSLog(@"About to send: %@ to: %@", params, url);
//	
//	[activityIndicator startAnimating];
	
//	ASIFormDataRequest* upRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
//	[upRequest setUseKeychainPersistance:YES];
//	[upRequest setUsername:@"admin"];
//	[upRequest setPassword:@"admin"];
	
//	if (image != nil) // take a screenshot of the movie to upload as well.
//	{
//		NSData* imgData = UIImagePNGRepresentation(image);	
//		[upRequest setData:imgData withFileName:imgName andContentType:@"image/png" forKey:@"image"];
//		
//	}
//	
//	if (movieUrl != nil)
//	{
//		NSData* movData = [[[NSData alloc] initWithContentsOfURL:movieUrl]autorelease];
//		[upRequest setData:movData withFileName:@"video.mov" andContentType:@"video/quicktime" forKey:@"movie"];
//	}
	
	//[upRequest setDelegate:self];
	
	//[upRequest setTimeOutSeconds:15];
//	
//	[upRequest startAsynchronous];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
	
	NSLog(@"Response: %@", [request responseString]);
	NSLog(@"Headers: %@	", [	request responseHeaders]);
	NSString* location = [[request responseHeaders] objectForKey:@"Location"];
	NSLog(@"LOCATION: %@", location);
	NSArray *components = [location	componentsSeparatedByString:@"/"];
	NSString* issueKey = [components lastObject];
//	if (issueKey == nil)
//	{
//		label.text	= @"Server Error";
//	} 
//	else {
//		
//		[button setTitle:@"View" forState:UIControlStateNormal	];
//		label.text = issueKey;
//	}
//	[activityIndicator stopAnimating];	
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	
	//[activityIndicator stopAnimating];
	
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
}

#pragma mark end


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"Picked Media: %@", info);
	UIImage* origImg = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
	[self dismissModalViewControllerAnimated:YES];
	[screenshotButton setBackgroundImage:origImg forState:UIControlStateNormal];
	
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

@synthesize sendButton, voiceButton, screenshotButton, descriptionField, subjectField, imagePicker;

- (void)dealloc {
    [super dealloc];
}


@end

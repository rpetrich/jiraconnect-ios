//
//  JCOTransport.m
//  JiraConnect
//
//  Created by Nick Pellow on 4/11/10.
//  Copyright 2010 Atlassian . All rights reserved.
//

#import "JCOTransport.h"
#import "JSON.h"
#import "JCO.h"


@implementation JCOTransport


-(void) send:(NSString*)subject description:(NSString*)description  screenshot:(UIImage*)screenshot  andVoiceData:(NSData*)voiceData
{
	NSLog(@"Sending feedback... %@, %@", subject, description);
	
	// issue creation url is:
	// curl -u admin:admin -F media=@image.png "http://localhost:2990/jira/rest/reallife/1.0/jirarl/upload?location=blah&pid=10000&issuetype=1&summary=testing123&reporter=admin"
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:subject forKey:@"summary"];
	[params setObject:description forKey:@"description"];
	NSDictionary* metaData = [[JCO instance] getMetaData];
	[params addEntriesFromDictionary:metaData];
	
	
	NSLog(@"App Data is :%@", params);
	
	NSURL* url = [NSURL URLWithString:@"jira/rest/jconnect/latest/issue" relativeToURL:[JCO instance].url];
	
	ASIFormDataRequest* upRequest = [ASIFormDataRequest requestWithURL:url];
	
	NSData* jsonData = [[params JSONRepresentation]	dataUsingEncoding:NSUTF8StringEncoding];
	[upRequest setData:jsonData withFileName:@"issue.json" andContentType:@"application/json" forKey:@"issue"];
	NSLog(@"About to send: %@ to: %@", [params JSONRepresentation], url);	
	
	if (screenshot != nil) // take a screenshot of the movie to upload as well.
	{
		NSData* imgData = UIImagePNGRepresentation(screenshot);	
		[upRequest setData:imgData withFileName:@"jiraconnect-screenshot.png" andContentType:@"image/png" forKey:@"screenshot"];
		
	}
	
	if (voiceData != nil) // also attach a recording
	{
		[upRequest setData:voiceData withFileName:@"voice-feedback.caf" andContentType:@"audio/x-caf" forKey:@"recording"];
	}
	
	NSLog(@"POST DATA: \n%@", jsonData);
	
	[upRequest setDelegate:self];
	[upRequest setTimeOutSeconds:15];
	[upRequest startAsynchronous];
}

#pragma mark UIAlertViewDelelgate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.delegate transportDidFinish];
}

#pragma mark ASIHTTPRequest

- (void)requestFinished:(ASIHTTPRequest *)request
{
	
	NSLog(@"Response: %@", [request responseString]);
	NSLog(@"Headers: %@	", [request responseHeaders]);
	NSString* location = [[request responseHeaders] objectForKey:@"Location"];
	NSLog(@"LOCATION: %@", location);
	NSArray *components = [location	componentsSeparatedByString:@"/"];
	NSString* issueKey = [components lastObject];
	NSLog(@"Got issue key: %@", issueKey);
    
    NSString* msg = [NSString stringWithFormat:@"Your feedback has been received. Thank you, for the common good."];
	NSLog(@"requestSuccess: %@", msg);
	UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"Thank you"
														 message:msg
														delegate:self 
											   cancelButtonTitle:@"OK"
											   otherButtonTitles:nil];
	[alertView2 show];
	[alertView2 release];
	
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	
	NSString* msg = [NSString stringWithFormat:@"\n %@.\n Please try again later.", [error localizedDescription]];
	NSLog(@"requestFailed: %@. URL: %@, response code: %d", msg, [request url], [request  responseStatusCode] );
	UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"Error submitting Feedback."
														 message:msg
														delegate:self 
											   cancelButtonTitle:@"Ok"
											   otherButtonTitles:nil];
	[alertView2 show];
	[alertView2 release];
	
}

#pragma mark end

@synthesize delegate=_delegate;

- (void) dealloc {
	[super dealloc];
	[_delegate release]; _delegate = nil;
}

@end

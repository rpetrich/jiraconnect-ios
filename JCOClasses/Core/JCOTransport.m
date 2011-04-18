//
//  JCOTransport.m
//  JiraConnect
//
//  Created by Nick Pellow on 4/11/10.
//

#import "JCOTransport.h"
#import "JSON.h"
#import "JCO.h"
#import "JCIssue.h"


@implementation JCOTransport


- (void)populateCommonFields:(NSString *)description screenshot:(UIImage *)screenshot voiceData:(NSData *)voiceData payloadData:(NSDictionary *)payloadData customFields:(NSDictionary *)customFields url:(NSURL *)url upRequest:(ASIFormDataRequest *)upRequest params:(NSMutableDictionary *)params {
    [params setObject:description forKey:@"description"];
    NSDictionary* metaData = [[JCO instance] getMetaData];
    [params addEntriesFromDictionary:metaData];
    NSData* jsonData = [[params JSONRepresentation]	dataUsingEncoding:NSUTF8StringEncoding];
    [upRequest setData:jsonData withFileName:@"issue.json" andContentType:@"application/json" forKey:@"issue"];
    NSLog(@"About to send: %@ to: %@", [params JSONRepresentation], url);
    if (screenshot != nil)
	{
		NSData* imgData = UIImagePNGRepresentation(screenshot);
		[upRequest setData:imgData withFileName:@"jiraconnect-screenshot.png" andContentType:@"image/png" forKey:@"screenshot"];

	}
    if (voiceData != nil)
	{
        NSLog(@"voiceData length: %d", [voiceData length]);
		[upRequest setData:voiceData withFileName:@"voice-feedback.caf" andContentType:@"audio/x-caf" forKey:@"recording"];
	}
    if (payloadData != nil)
    {
        NSData *json = [[payloadData JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
        [upRequest setData:json withFileName:@"payload.txt" andContentType:@"plain/text" forKey:@"payload"];
    }
    if (customFields != nil)
    {
        NSData *json = [[customFields JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
        [upRequest setData:json withFileName:@"customfields.json" andContentType:@"application/json" forKey:@"customfields"];
    }
}

- (void)send:(NSString *)subject
        description:(NSString *)description
        screenshot:(UIImage *)screenshot
        voiceData:(NSData *)voiceData
        payload:(NSDictionary *)payloadData
        fields:(NSDictionary *)customFields {
    
	NSLog(@"Sending feedback... %@, %@ %@", subject, description, payloadData, customFields);
	
	// issue creation url is:
	// curl -u admin:admin -F media=@image.png "http://localhost:2990/jira/rest/reallife/1.0/jirarl/upload?location=blah&pid=10000&issuetype=1&summary=testing123&reporter=admin"

    NSURL* url = [NSURL URLWithString:@"rest/jconnect/latest/issue" relativeToURL:[JCO instance].url];

    ASIFormDataRequest* upRequest = [ASIFormDataRequest requestWithURL:url];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:subject forKey:@"summary"];
    [self populateCommonFields:description screenshot:screenshot voiceData:voiceData payloadData:payloadData customFields:customFields url:url upRequest:upRequest params:params];
    [upRequest setDelegate:self];
	[upRequest setTimeOutSeconds:15];
	[upRequest startAsynchronous];
}

- (void)sendReply:(JCIssue *)originalIssue description:(NSString *)description screenshot:(UIImage *)screenshot voiceData:(NSData *)voiceData payload:(NSDictionary *)payloadData fields:(NSDictionary *)customFields {

    NSLog(@"Sending reply... %@, %@ %@", originalIssue.key, description, payloadData, customFields);

	// issue creation url is:
	// curl -u admin:admin -F media=@image.png "http://localhost:2990/jira/rest/reallife/1.0/jirarl/upload?location=blah&pid=10000&issuetype=1&summary=testing123&reporter=admin"

    NSString *path = [NSString stringWithFormat:@"rest/jconnect/latest/issue/%@", originalIssue.key];
    NSURL* url = [NSURL URLWithString:path relativeToURL:[JCO instance].url];

    ASIFormDataRequest* upRequest = [ASIFormDataRequest requestWithURL:url];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self populateCommonFields:description screenshot:screenshot voiceData:voiceData payloadData:payloadData customFields:customFields url:url upRequest:upRequest params:params];
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
	NSLog(@"Headers: %@	", [request responseHeaders]);

	NSLog(@"Got issue key: %@", [request responseString]);
    
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
    self.delegate = nil;
    [super dealloc];
}


@end

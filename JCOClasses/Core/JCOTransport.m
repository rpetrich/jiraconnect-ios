//
//  JCOTransport.m
//  JiraConnect
//
//  Created by Nick Pellow on 4/11/10.
//

#import "JCOTransport.h"
#import "JSON.h"
#import "JCO.h"

@implementation JCOTransport

- (void)populateCommonFields:(NSString *)description
                  screenshot:(UIImage *)screenshot
                   voiceData:(NSData *)voiceData
                 payloadData:(NSDictionary *)payloadData
                customFields:(NSDictionary *)customFields
                   upRequest:(ASIFormDataRequest *)upRequest
                      params:(NSMutableDictionary *)params {

    [params setObject:description forKey:@"description"];
    NSDictionary *metaData = [[JCO instance] getMetaData];
    [params addEntriesFromDictionary:metaData];
    NSData *jsonData = [[params JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    [upRequest setData:jsonData withFileName:@"issue.json" andContentType:@"application/json" forKey:@"issue"];
    if (screenshot != nil) {
        NSData *imgData = UIImagePNGRepresentation(screenshot);
        [upRequest setData:imgData withFileName:@"jiraconnect-screenshot.png" andContentType:@"image/png" forKey:@"screenshot"];
    }
    if (voiceData != nil) {
        [upRequest setData:voiceData withFileName:@"voice-feedback.caf" andContentType:@"audio/x-caf" forKey:@"recording"];
    }
    if (payloadData != nil) {
        NSData *json = [[payloadData JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
        [upRequest setData:json withFileName:@"payload.txt" andContentType:@"plain/text" forKey:@"payload"];
    }
    if (customFields != nil) {
        NSData *json = [[customFields JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
        [upRequest setData:json withFileName:@"customfields.json" andContentType:@"application/json" forKey:@"customfields"];
    }
}

#pragma mark ASIHTTPRequest

- (void)alert:(NSString *)msg withTitle:(NSString *)title button:(NSString *)button {
    UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:title
                message:msg
                delegate:self
                cancelButtonTitle:button
                otherButtonTitles:nil];
    [alertView2 show];
    [alertView2 release];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"Headers: %@	", [request responseHeaders]);

    NSLog(@"Got issue key: %@", [request responseString]);
    if (request.responseStatusCode == 200) {

        NSString *msg = [NSString stringWithFormat:@"Your feedback has been received. Thank you, for the common good."];
        NSLog(@"requestSuccess: %@", msg);
        [self alert:msg withTitle:@"Thank you" button:@"OK"];
        // alert the delegate!
        // TODO: also alert on FAIL...
        [self.delegate transportDidFinish];

    } else {
        NSString *msg = [NSString stringWithFormat:@"There was an error submitting your feedback. Please try again soon."];
        NSLog(@"requestFail: %d, %@", request.responseStatusCode, msg);
        [self alert:msg withTitle:@"Submission Error" button:@"OK"];        
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];

    NSString *msg = [NSString stringWithFormat:@"\n %@.\n Please try again later.", [error localizedDescription]];
    NSLog(@"requestFailed: %@. URL: %@, response code: %d", msg, [request url], [request responseStatusCode]);
    [self alert:msg withTitle:@"Error submitting Feedback" button:@"OK"];
}

#pragma mark end

@synthesize delegate = _delegate;

- (void)dealloc {
    self.delegate = nil;
    [super dealloc];
}


@end

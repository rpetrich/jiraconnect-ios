
#import "JCOTransport.h"
#import "JSON.h"
#import "JCO.h"
#import "JCOAttachmentItem.h"

@implementation JCOTransport

- (void)populateCommonFields:(NSString *)description images:(NSArray *)attachments payloadData:(NSDictionary *)payloadData customFields:(NSDictionary *)customFields upRequest:(ASIFormDataRequest *)upRequest params:(NSMutableDictionary *)params {

    [params setObject:description forKey:@"description"];
    NSDictionary *metaData = [[JCO instance] getMetaData];
    [params addEntriesFromDictionary:metaData];
    NSData *jsonData = [[params JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    [upRequest setData:jsonData withFileName:@"issue.json" andContentType:@"application/json" forKey:@"issue"];

    if (attachments != nil) {
        for (int i = 0; i < [attachments count]; i++) {
            JCOAttachmentItem *item = [attachments objectAtIndex:i];
            NSString *filename = [NSString stringWithFormat:item.filenameFormat, i];
            NSString *key = [item.name stringByAppendingFormat:@"-%d", i];
            [upRequest setData:item.data withFileName:filename andContentType:item.contentType forKey:key];
        }
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
    
    NSLog(@"Response for %@ is %@", request.url,  [request responseString]);
    if (request.responseStatusCode < 300) {

        NSString *msg = [NSString stringWithFormat:@"Your feedback has been received. Thank you, for the common good."];
        [self alert:msg withTitle:@"Thank you" button:@"OK"];
        // alert the delegate!
        // TODO: also alert on FAIL...
        [self.delegate transportDidFinish];

    } else {
        [self requestFailed:request];
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if ([self.delegate respondsToSelector:@selector(transportDidFinishWithError:)]) {
        [self.delegate transportDidFinishWithError:error];
    }
    NSString *msg = @"";
    if (request.responseStatusCode >= 300) {
        msg = [msg stringByAppendingFormat:@"Response code %d\n", request.responseStatusCode];
    }
    if ([error localizedDescription] != nil) {
        msg = [msg stringByAppendingFormat:@"%@.\n", [error localizedDescription]];
    }
    msg = [msg stringByAppendingString:@"Please try again later."];
    
    NSLog(@"requestFailed: %@ URL: %@, response code: %d", msg, [request url], [request responseStatusCode]);
    [self alert:msg withTitle:@"Error submitting Feedback" button:@"OK"];
}

#pragma mark end

@synthesize delegate = _delegate;

- (void)dealloc {
    self.delegate = nil;
    [super dealloc];
}


@end

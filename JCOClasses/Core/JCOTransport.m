#import "JCOMacros.h"
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
    
    if(attachments != nil);
    {
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
    
    NSLog(@"Response '%@' for %@", request.responseString, request.url.absoluteURL);
    if (request.responseStatusCode < 300) {

        NSString *thankyouMsg = JCOLocalizedString(@"JCOFeedbackReceived", @"Thank you message on successful feedback submission");
        NSString *msg = [NSString stringWithFormat:thankyouMsg, [[JCO instance] getProject]];
        [self alert:msg withTitle:@"Thank You" button:@"OK"];
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
    
    NSLog(@"requestFailed: %@ URL: %@, response code: %d", msg, [[request url] absoluteURL], [request responseStatusCode]);
    [self alert:msg withTitle:@"Error submitting Feedback" button:@"OK"];
}

#pragma mark end

@synthesize delegate = _delegate;

- (void)dealloc {
    self.delegate = nil;
    [super dealloc];
}


+ (CFStringRef)newEncodedValue:(CFStringRef)value {
    return CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
            value,
            NULL,
            (CFStringRef) @";/?:@&=+$,",
            kCFStringEncodingUTF8);
}


+ (NSMutableString *)encodeParameters:(NSDictionary *)parameters {
    NSMutableString *params = nil;
    if (parameters != nil) {
        params = [[NSMutableString alloc] init];
        for (id key in parameters) {
            NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            CFStringRef value = (CFStringRef) [[parameters objectForKey:key] copy];

            // Escape even the "reserved" characters for URLs
            // as defined in http://www.ietf.org/rfc/rfc2396.txt
            CFStringRef encodedValue = [self newEncodedValue:value];

            [params appendFormat:@"%@=%@&", encodedKey, encodedValue];

            CFRelease(value);
            CFRelease(encodedValue);
        }
        [params deleteCharactersInRange:NSMakeRange([params length] - 1, 1)];
    }
    return [params autorelease];

}


@end

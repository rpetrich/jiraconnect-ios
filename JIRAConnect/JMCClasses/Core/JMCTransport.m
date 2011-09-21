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
#import "JMCMacros.h"
#import "JMCTransport.h"
#import "JSON.h"
#import "JMC.h"
#import "JMCAttachmentItem.h"
#import "JMCQueueItem.h"
#import "JMCRequestQueue.h"

@implementation JMCTransport


- (void)populateCommonFields:(NSString *)description attachments:(NSArray *)attachments upRequest:(ASIFormDataRequest *)upRequest params:(NSMutableDictionary *)params {

    // write each data part to disk with a unique filename uuid-ID
    // store metadata in an index file: uid-index. Contains: URL, parameters(key=value pairs), parts(contentType, name, filename)
    [params setObject:description forKey:@"description"];
    [params addEntriesFromDictionary:[[JMC instance] getMetaData]];
    
    NSData *jsonData = [[params JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    JMCAttachmentItem *issueItem = [[JMCAttachmentItem alloc] initWithName:@"issue"
                                                                      data:jsonData
                                                                      type:JMCAttachmentTypeSystem
                                                               contentType:@"application/json"
                                                            filenameFormat:@"issue.json"];
    
    
    NSMutableArray *allAttachments = [NSMutableArray array];
    [allAttachments addObject:issueItem];
    [issueItem release];
    
    if (attachments != nil) {
        [allAttachments addObjectsFromArray:attachments];
    }
    
    for (u_int i = 0; i < [allAttachments count]; i++) {
        JMCAttachmentItem *item = [allAttachments objectAtIndex:i];
        if (item != nil) {
            NSString *filename = [NSString stringWithFormat:item.filenameFormat, i];
            NSString *key = [item.name stringByAppendingFormat:@"-%d", i];
            if (item.type == JMCAttachmentTypeCustom ||
                item.type == JMCAttachmentTypeSystem) {
                // the JIRA Plugin expects all customfields to be in the 'customfields' part.
                // If this changes, plugin must change too
                [upRequest setData:item.data withFileName:filename andContentType:item.contentType forKey:item.name];
            } else {
                [upRequest addData:item.data withFileName:filename andContentType:item.contentType forKey:key];
            }
        }
    }

    JMCQueueItem* queueItem = [[JMCQueueItem alloc] initWith:@"uuid-TODO"
                                                         url:[upRequest.url absoluteString]
                                                  parameters:params
                                                  attachments:allAttachments];
    JMCRequestQueue *queue = [JMCRequestQueue sharedInstance];
    [queue addItem:queueItem];
    [queueItem release];

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

    if (request.responseStatusCode < 300) {

        NSString *thankyouMsg = JMCLocalizedString(@"JMCFeedbackReceived", @"Thank you message on successful feedback submission");
        NSString *msg = [NSString stringWithFormat:thankyouMsg, [[JMC instance] getProject]];
        [self alert:msg withTitle:@"Thank You" button:@"OK"];
        // alert the delegate!
        [self.delegate transportDidFinish:[request responseString]];
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

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

#define kJMCHeaderNameRequestId @"-x-jmc-requestid"

@implementation JMCTransport

+(NSString *)encodeCommonParameters
{
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithCapacity:2];
    [queryParams setObject:[[JMC instance] getProject] forKey:@"project"];
    [queryParams setObject:[[JMC instance] getApiKey]  forKey:@"apikey"];
    return [JMCTransport encodeParameters:queryParams];
}

+(void)addAllAttachments:(NSArray *)allAttachments toRequest:(ASIFormDataRequest *)upRequest
{
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
}

- (NSString *) getType {
    return nil;
}
- (NSString *) getIssueKey {
    return nil;
}
- (NSURL *) makeUrlFor:(NSString *)issueKey {
    return nil;
}

- (void) resendItem:(JMCQueueItem *)item {

    // only ASIFormDataRequest are queued at the moment...
    NSURL *url = [self makeUrlFor:item.originalIssueKey];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    [JMCTransport addAllAttachments:item.attachments toRequest:request];

    [request setShouldContinueWhenAppEntersBackground:YES];
    [request addRequestHeader:kJMCHeaderNameRequestId value:item.uuid];
    [request setDelegate:self];
    NSLog(@"ASIHTTP Request delegate is: %@", request.delegate);
    [request setShouldAttemptPersistentConnection:NO];
    [request setTimeOutSeconds:30];
    [request startSynchronous];
}

-(void)sayThankYou {
    NSString *thankyouMsg = JMCLocalizedString(@"JMCFeedbackReceived", @"Thank you message on successful feedback submission");
    NSString *appName = [[JMC instance] getAppName];
    NSString *projectName = appName ? appName : [[JMC instance] getProject];
    NSString *msg = [NSString stringWithFormat:thankyouMsg, projectName];

    UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"Thank You"
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
    [alertView2 show];
    [alertView2 release];
}

- (JMCQueueItem *)populateCommonFields:(NSString *)description
                           attachments:(NSArray *)attachments
                             upRequest:(ASIFormDataRequest *)upRequest
                                params:(NSMutableDictionary *)params
                              issueKey:(NSString *)issueKey
{

    // write each data part to disk with a unique filename uuid-ID
    // store metadata in an index file: uid-index. Contains: URL, parameters(key=value pairs), parts(contentType, name, filename)
    [params setObject:description forKey:@"description"];
    [params addEntriesFromDictionary:[[JMC instance] getMetaData]];

    NSString *issueJSON = [params JSONRepresentation];
    NSData *jsonData = [issueJSON dataUsingEncoding:NSUTF8StringEncoding];
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

    [JMCTransport addAllAttachments:allAttachments toRequest:upRequest];

    [upRequest setShouldContinueWhenAppEntersBackground:YES];
    [upRequest setDelegate:self];
    [upRequest setShouldAttemptPersistentConnection:NO];
    [upRequest setTimeOutSeconds:30];

    NSLog(@"Foreground submission: ASIHTTP Request delegate: %@", upRequest.delegate);

    NSString *requestId= [JMCQueueItem generateUniqueId];
    [upRequest addRequestHeader:kJMCHeaderNameRequestId value:requestId];

    JMCQueueItem *queueItem = [[JMCQueueItem alloc] initWith:requestId
                                                         url:[upRequest.url absoluteString]
                                                        type:[self getType]
                                                 attachments:allAttachments
                                                    issueKey:issueKey];
    
    [self.delegate transportWillSend:issueJSON requestId:requestId];

    return [queueItem autorelease];
}


#pragma mark ASIHTTPRequest

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSString *requestId = [request.requestHeaders objectForKey:kJMCHeaderNameRequestId];
    if (request.responseStatusCode < 300) {

        // remove the request item from the queue
        //TODO: consider synchronisation

        NSLog(@"Request success: Transport delegate = %@", self.delegate);
        [self.delegate transportDidFinish:[request responseString] requestId:requestId];

        JMCRequestQueue *queue = [JMCRequestQueue sharedInstance];
        [queue deleteItem:requestId];
        NSLog(@"Request succeeded & queued item is deleted. %@ ", requestId);
        // alert the delegate!
    } else {
        NSLog(@"Request FAILED & queued item is not deleted. %@", requestId);
        [self requestFailed:request];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSString *requestId = [request.requestHeaders objectForKey:kJMCHeaderNameRequestId];
    NSError *error = [request error];
    if ([self.delegate respondsToSelector:@selector(transportDidFinishWithError:requestId:)]) {
        [self.delegate transportDidFinishWithError:error requestId:requestId];
    }
    NSString *msg = @"";
    if ([error localizedDescription] != nil) {
        msg = [msg stringByAppendingFormat:@"%@.\n", [error localizedDescription]];
    }
    NSString *response= [request responseString];
    if (response) {
        msg = [msg stringByAppendingString:response];
    }

    NSLog(@"Request failed: %@ URL: %@, response code: %d", msg, [[request url] absoluteURL], [request responseStatusCode]);
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

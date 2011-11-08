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
#import "JMC.h"
#import "JMCAttachmentItem.h"
#import "JMCQueueItem.h"
#import "JMCRequestQueue.h"
#import "JMCTransportOperation.h"

@implementation JMCTransport

+(NSString *)encodeCommonParameters
{
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithCapacity:2];
    [queryParams setObject:[[JMC instance] getProject] forKey:@"project"];
    [queryParams setObject:[[JMC instance] getApiKey]  forKey:@"apikey"];
    return [JMCTransport encodeParameters:queryParams];
}

+(void)addAllAttachments:(NSArray *)allAttachments toRequest:(NSMutableURLRequest *)request boundary:(NSString *)boundary
{
    NSMutableData *body = [NSMutableData dataWithCapacity:0];

    NSMutableDictionary *unique = [[NSMutableDictionary alloc] init];
    
    // Ignore for now
    NSInteger index = 0;
    for (u_int i = 0; i < [allAttachments count]; i++) {
        JMCAttachmentItem *item = [allAttachments objectAtIndex:i];
        if (item != nil && item.filenameFormat != nil) {

            NSString *filename = [NSString stringWithFormat:item.filenameFormat, index];
            NSString *key = [item.name stringByAppendingFormat:@"-%d", index];
            NSLog(@"%@=%@ (%@)", key, item.data, item.contentType);
            if (item.type == JMCAttachmentTypeCustom ||
                item.type == JMCAttachmentTypeSystem) {
                // the JIRA Plugin expects all customfields to be in the 'customfields' part.
                // If this changes, plugin must change too
                [unique setValue:item forKey:item.name];
            } else {
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, filename] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", item.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:item.data];
                [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                index++;
            }
        }
    }
    
    for (NSString *key in unique) {
        JMCAttachmentItem *item = [unique valueForKey:key];
        NSString *filename = [NSString stringWithFormat:item.filenameFormat, index];
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", item.name, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", item.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:item.data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        index++;
    }
    [unique release];
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
}

+ (id)parseJSONString:(NSString *)jsonString {
    NSError *error = nil;
    id feedResult = nil;
    
    SEL sbJSONSelector = NSSelectorFromString(@"JSONValue");
    SEL jsonKitSelector = NSSelectorFromString(@"objectFromJSONStringWithParseOptions:error:");
    
    if (jsonKitSelector && [jsonString respondsToSelector:jsonKitSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[jsonString methodSignatureForSelector:jsonKitSelector]];
        invocation.target = jsonString;
        invocation.selector = jsonKitSelector;
        int parseOptions = 0;
        [invocation setArgument:&parseOptions atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
        [invocation getReturnValue:&feedResult];
    } 
    else if (sbJSONSelector && [jsonString respondsToSelector:sbJSONSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[jsonString methodSignatureForSelector:sbJSONSelector]];
        invocation.target = jsonString;
        invocation.selector = sbJSONSelector;
        [invocation invoke];
        [invocation getReturnValue:&feedResult];
    } else {
        JMCALog(@"Error: You need a JSON Framework in your runtime!");
        [self doesNotRecognizeSelector:_cmd];
    }    
    if (error) {
        JMCALog(@"Error while parsing response feed: %@", [error localizedDescription]);
        return nil;
    }
    
    return feedResult;
}

+ (NSString *)buildJSONString:(id)object {
    NSError *error = nil;
    id stringResult = nil;
    
    SEL sbJSONSelector = NSSelectorFromString(@"JSONRepresentation");
    SEL jsonKitSelector = NSSelectorFromString(@"JSONString");
    
    if (jsonKitSelector && [object respondsToSelector:jsonKitSelector]) {
        stringResult = [object performSelector:jsonKitSelector];
    } 
    else if (sbJSONSelector && [object respondsToSelector:sbJSONSelector]) {
        stringResult = [object performSelector:sbJSONSelector];
    } else {
        JMCALog(@"Error: You need a JSON Framework in your runtime!");
        [self doesNotRecognizeSelector:_cmd];
    }    
    if (error) {
        JMCALog(@"Error while parsing response feed: %@", [error localizedDescription]);
        return nil;
    }
    
    return stringResult;
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

- (NSString *)hashForConnection:(NSURLConnection *)connection {
    return [NSString stringWithFormat:@"%ld", connection];
}

- (JMCTransportOperation *) requestFromItem:(JMCQueueItem *)item
{
    // Bounday for multi-part upload
    static NSString *boundary = @"JMCf06ddca8d02e6810c0a7e3e9e9086da87f07080f";

    // Get URL
    NSURL *url = [self makeUrlFor:item.originalIssueKey];
    if (!url) {
        JMCALog(@"Invalid URL made for original issue key: %@", item.originalIssueKey);
        return nil;
    }

    // FIXME: Replace by own solution
    //[request setShouldContinueWhenAppEntersBackground:YES];
    
    // Create request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    [request setValue:item.uuid forHTTPHeaderField:kJMCHeaderNameRequestId];
    request.timeoutInterval = 60;

    [JMCTransport addAllAttachments:item.attachments toRequest:request boundary:boundary];

    JMCTransportOperation *operation = [JMCTransportOperation operationWithRequest:request delegate:self.delegate];
    
    return operation;
}

-(void)sayThankYou {
    NSString *thankyouMsg = JMCLocalizedString(@"JMCFeedbackReceived", @"Thank you message on feedback submission");
    NSString *appName = [[JMC instance] getAppName];
    NSString *projectName = appName ? appName : [[JMC instance] getProject];
    NSString *msg = [NSString stringWithFormat:thankyouMsg, projectName];

    NSString *thankyouTitle = JMCLocalizedString(@"Thank You", @"Thank you title on feedback submission");
    UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:thankyouTitle
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
    [alertView2 show];
    [alertView2 release];
}

- (JMCQueueItem *)qeueItemWith:(NSString *)description
                   attachments:(NSArray *)attachments
                        params:(NSMutableDictionary *)params
                      issueKey:(NSString *)issueKey
{

    // write each data part to disk with a unique filename uuid-ID
    // store metadata in an index file: uid-index. Contains: URL, parameters(key=value pairs), parts(contentType, name, filename)
    [params setObject:description forKey:@"description"];
    [params addEntriesFromDictionary:[[JMC instance] getMetaData]];

    NSString *issueJSON = [[self class] buildJSONString:params];
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

    NSString *requestId = [JMCQueueItem generateUniqueId];

    JMCQueueItem *queueItem = [[JMCQueueItem alloc] initWith:requestId
                                                        type:[self getType]
                                                 attachments:allAttachments
                                                    issueKey:issueKey];

    [self.delegate transportWillSend:issueJSON requestId:requestId issueKey:issueKey];

    return [queueItem autorelease];
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

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
//
//  Created by nick on 13/05/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCTransport.h"
#import "JMCCrashTransport.h"
#import "JMC.h"

@implementation JMCCrashTransport

- (void)send:(NSString *)subject description:(NSString *)description crashReport:(NSString *)crashReport {

    NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithCapacity:2];
    [queryParams setObject:[[JMC instance] getProject] forKey:@"project"];
    [queryParams setObject:[[JMC instance] getApiKey]  forKey:@"apikey"];

    NSString *queryString = [JMCTransport encodeParameters:queryParams];
    NSString *path = [NSString stringWithFormat:kJMCTransportCreateIssuePath, [[JMC instance] getAPIVersion], queryString];
    NSURL *url = [NSURL URLWithString:path relativeToURL:[JMC instance].url];
    NSLog(@"Sending crash report to:   %@", url.absoluteString);
    ASIFormDataRequest *upRequest = [ASIFormDataRequest requestWithURL:url];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:subject forKey:@"summary"];
    NSString *typeName = [[JMC instance] issueTypeNameFor:JMCIssueTypeCrash useDefault:@"Crash"];
    [params setObject:typeName forKey:@"type"];
    [self populateCommonFields:description attachments:nil upRequest:upRequest params:params];
    NSData *crashData = [crashReport dataUsingEncoding:NSUTF8StringEncoding];
    // 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    // TODO: use the actual crash date for this file extension
    // TODO: sanitize AppName for spaces, puntuation, etc..
    NSString* filename = 
        [[[JMC instance] getAppName] stringByAppendingFormat:@"-%@.crash", [dateFormatter stringFromDate:[NSDate date]]];
    [dateFormatter release];
    
    [upRequest setData:crashData withFileName:filename andContentType:@"text/plain" forKey:@"crash"];
    [upRequest setDelegate:self];
    [upRequest setShouldAttemptPersistentConnection:NO];
    [upRequest setTimeOutSeconds:15];
    [upRequest startAsynchronous];

}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if (request.responseStatusCode < 300) {
        NSLog(@"Crash sent: %@", [request responseString]);
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

    NSString * errMsg = [error localizedDescription] != nil ? [error localizedDescription] : @"";
    NSString *msg = [NSString stringWithFormat:@"\n %@: %@\n Please try again later.", errMsg, [request responseString]];
    NSLog(@"CRASH requestFailed: %@. URL: %@, response code: %d", msg, [request url], [request responseStatusCode]);
}


@end
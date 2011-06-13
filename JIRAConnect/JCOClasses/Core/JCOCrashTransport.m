/**
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
*/


#import "JCOTransport.h"
#import "JCOCrashTransport.h"
#import "JCO.h"

@implementation JCOCrashTransport

- (void)send:(NSString *)subject description:(NSString *)description crashReport:(NSString *)crashReport {

    NSDictionary *queryParams = [NSDictionary dictionaryWithObject:[[JCO instance] getProject] forKey:@"project"];
    NSString *queryString = [JCOTransport encodeParameters:queryParams];
    NSString *path = [NSString stringWithFormat:kJCOTransportCreateIssuePath, queryString];
    NSURL *url = [NSURL URLWithString:path relativeToURL:[JCO instance].url];
    NSLog(@"Sending crash report to:   %@", url.absoluteString);
    ASIFormDataRequest *upRequest = [ASIFormDataRequest requestWithURL:url];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:subject forKey:@"summary"];
    [params setObject:@"Crash" forKey:@"type"]; // this is used, if there is an issueType in JIRA named 'Crash'.
    [self populateCommonFields:description images:nil payloadData:nil customFields:nil upRequest:upRequest params:params];
    NSData *crashData = [crashReport dataUsingEncoding:NSUTF8StringEncoding];
    // 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    // TODO: use the actual crash date for this file extension
    // TODO: sanitize AppName for spaces, puntuation, etc..
    NSString* filename = 
        [[[JCO instance] getAppName] stringByAppendingFormat:@"-%@.crash", [dateFormatter stringFromDate:[NSDate date]]];
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
    NSString *msg = [NSString stringWithFormat:@"\n %@.\n Please try again later.", [error localizedDescription]];
    NSLog(@"CRASH requestFailed: %@. URL: %@, response code: %d", msg, [request url], [request responseStatusCode]);
}


@end
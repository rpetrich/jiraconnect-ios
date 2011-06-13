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
#import "JCOReplyTransport.h"
#import "JCO.h"

@implementation JCOReplyTransport

- (void)sendReply:(JCOIssue *)originalIssue description:(NSString *)description images:(NSArray *)images payload:(NSDictionary *)payloadData fields:(NSDictionary *)customFields {

    NSString *path = [NSString stringWithFormat:kJCOTransportCreateCommentPath, originalIssue.key];
    NSURL *url = [NSURL URLWithString:path relativeToURL:[JCO instance].url];
    NSLog(@"Sending reply report to:   %@", url.absoluteString);
    ASIFormDataRequest *upRequest = [ASIFormDataRequest requestWithURL:url];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self populateCommonFields:description images:images payloadData:payloadData customFields:customFields upRequest:upRequest params:params];
    
    [upRequest setDelegate:self];
    [upRequest setShouldAttemptPersistentConnection:NO];
    [upRequest setTimeOutSeconds:15];
    [upRequest startAsynchronous];

    // TODO: consider doing this only if request is successful. Else, remove last comment on FAIL?
    JCOComment * comment = [[JCOComment alloc] initWithAuthor:@"Author" systemUser:YES body:description date:[NSDate date]];
    [originalIssue.comments addObject:comment];
    [comment release];
}

#pragma mark UIAlertViewDelelgate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // dismiss modal dialog. 

}
#pragma end

@end
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
//  Created by nick on 28/04/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCTransport.h"
#import "JMCReplyTransport.h"
#import "../JMC.h"

@implementation JMCReplyTransport

- (void)sendReply:(JMCIssue *)originalIssue description:(NSString *)description images:(NSArray *)images payload:(NSDictionary *)payloadData fields:(NSDictionary *)customFields {

    NSString *path = [NSString stringWithFormat:kJCOTransportCreateCommentPath, originalIssue.key];
    NSURL *url = [NSURL URLWithString:path relativeToURL:[JMC instance].url];
    NSLog(@"Sending reply report to:   %@", url.absoluteString);
    ASIFormDataRequest *upRequest = [ASIFormDataRequest requestWithURL:url];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self populateCommonFields:description images:images payloadData:payloadData customFields:customFields upRequest:upRequest params:params];
    
    [upRequest setDelegate:self];
    [upRequest setShouldAttemptPersistentConnection:NO];
    [upRequest setTimeOutSeconds:15];
    [upRequest startAsynchronous];

    // TODO: consider doing this only if request is successful. Else, remove last comment on FAIL?
    JMCComment * comment = [[JMCComment alloc] initWithAuthor:@"Author" systemUser:YES body:description date:[NSDate date]];
    [originalIssue.comments addObject:comment];
    [comment release];
}

#pragma mark UIAlertViewDelelgate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // dismiss modal dialog. 

}
#pragma end

@end
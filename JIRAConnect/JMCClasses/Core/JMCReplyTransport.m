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

#import "JMCTransport.h"
#import "JMCReplyTransport.h"
#import "JMC.h"
#import "JMCQueueItem.h"
#import "JMCRequestQueue.h"

@implementation JMCReplyTransport

-(NSURL *)makeUrlFor:(NSString*)issueKey
{
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithCapacity:2];
    [queryParams setObject:[[JMC instance] getProject] forKey:@"project"];
    [queryParams setObject:[[JMC instance] getApiKey] forKey:@"apikey"];
    NSString *queryString = [JMCTransport encodeParameters:queryParams];
    NSString *path = [NSString stringWithFormat:kJMCTransportCreateCommentPath, [[JMC instance] getAPIVersion], issueKey, queryString];
    return [NSURL URLWithString:path relativeToURL:[JMC instance].url];
}

-(NSString *) getType
{
    return kTypeReply;
}

- (void)sendReply:(JMCIssue *)originalIssue
      description:(NSString *)description
      attachments:(NSArray *)attachments
{

    NSURL *url = [self makeUrlFor:originalIssue.key];
    NSLog(@"Sending reply report to: %@ - delegate %@", url.absoluteString, self.delegate);
    ASIFormDataRequest *upRequest = [ASIFormDataRequest requestWithURL:url];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    JMCQueueItem *queueItem =
            [self populateCommonFields:description attachments:attachments upRequest:upRequest params:params issueKey:originalIssue.key];
    JMCRequestQueue *queue = [JMCRequestQueue sharedInstance];
    [queue addItem:queueItem];
    [upRequest startAsynchronous];
    
}

#pragma mark UIAlertViewDelelgate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // dismiss modal dialog. 

}
#pragma end

@end
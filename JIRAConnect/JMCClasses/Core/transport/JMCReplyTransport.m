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
    NSString *queryString = [JMCTransport encodeCommonParameters];
    NSString *path = [NSString stringWithFormat:kJMCTransportCreateCommentPath, [[JMC sharedInstance] getAPIVersion], issueKey, queryString];
    return [NSURL URLWithString:path relativeToURL:[JMC sharedInstance].url];
}

-(NSString *) getType
{
    return kTypeReply;
}

- (void)sendReply:(JMCIssue *)originalIssue
      description:(NSString *)description
      attachments:(NSArray *)attachments
{

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    JMCQueueItem *queueItem = [self qeueItemWith:description
                                     attachments:attachments
                                          params:params
                                        issueKey:originalIssue.key];
    JMCRequestQueue *queue = [JMCRequestQueue sharedInstance];
    [queue addItem:queueItem];
    [[JMC sharedInstance] flushRequestQueue];

}

@end
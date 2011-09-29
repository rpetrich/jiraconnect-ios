//
//  Created by niick on 27/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCReplyDelegate.h"
#import "JMCIssueStore.h"
#import "JMCRequestQueue.h"
#import "JSON.h"
#import "JMC.h"
#import "JMCComment.h"

@implementation JMCReplyDelegate

#pragma mark JMCTransportDelegate

- (void)transportWillSend:(NSString *)entityJSON requestId:(NSString *)requestId issueKey:(NSString *)issueKey
{
    // create a comment to be inserted in the db
    NSDictionary *responseDict = [entityJSON JSONValue];
    NSString* description = [responseDict objectForKey:@"description"];
    JMCComment *comment = [[JMCComment alloc] initWithAuthor:@"jiraconnectuser"
                                                  systemUser:YES
                                                        body:description
                                                        date:[NSDate date]
                                                        uuid:requestId
                                                        sent:NO];

    [[JMCIssueStore instance] insertComment:comment forIssue:issueKey];
    [comment release];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kJMCNewCommentCreated object:nil]];
}

- (void)transportDidFinish:(NSString *)response requestId:(NSString *)requestId
{
    JMCIssueStore *store = [JMCIssueStore instance];
    
    if ([store commentExistsIssueByUUID:requestId]) {
        // update comment in db as sent!
        [store setSentStatus:JMCSentStatusSuccess forComment:requestId];
        NSLog(@"Comment added to JIRA and marked as sent: %@", response);
    } else {
        // insert a new comment.... a ping notification may have dropped the db
        NSDictionary *commentDict = [response JSONValue];
        JMCComment *comment = [JMCComment newCommentFromDict:commentDict];
        NSString *issueKey = [commentDict valueForKey:@"issueKey"];
        NSLog(@"Comment inserted for JIRA %@ and marked as sent: %@", issueKey, requestId);
        comment.sentStatus = JMCSentStatusSuccess;
        comment.uuid = requestId;
        [store insertComment:comment forIssue:issueKey];
        [comment release];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kJMCNewCommentCreated object:nil]];
    }
}

- (void)transportDidFinishWithError:(NSError *)error requestId:(NSString *)requestId
{
    [[JMCIssueStore instance] setSentStatus:JMCSentStatusRetry forComment:requestId];
}

#pragma end 

@end
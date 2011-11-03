//
//  Created by niick on 27/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCReplyDelegate.h"
#import "JMCIssueStore.h"
#import "JMCRequestQueue.h"
#import "JMC.h"
#import "JMCComment.h"
#import "JMCMacros.h"
#import "JMCTransport.h"

@implementation JMCReplyDelegate

#pragma mark JMCTransportDelegate

- (void)transportWillSend:(NSString *)entityJSON requestId:(NSString *)requestId issueKey:(NSString *)issueKey
{
    // create a comment to be inserted in the db
    NSDictionary *responseDict = [JMCTransport parseJSONString:entityJSON];
    NSString* description = [responseDict objectForKey:@"description"];
    JMCComment *comment = [[JMCComment alloc] initWithAuthor:@"jiraconnectuser"
                                                  systemUser:YES
                                                        body:description
                                                        date:[NSDate date]
                                                        requestId:requestId];

    [[JMCIssueStore instance] insertComment:comment forIssue:issueKey];
    [comment release];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kJMCNewCommentCreated object:nil]];
}

- (void)transportDidFinish:(NSString *)response requestId:(NSString *)requestId
{
    JMCIssueStore *store = [JMCIssueStore instance];
    
    if (![store commentExistsIssueByUUID:requestId])
    {
        // insert a new comment.... a ping notification may have dropped the db
        NSDictionary *commentDict = [JMCTransport parseJSONString:response];
        JMCComment *comment = [JMCComment newCommentFromDict:commentDict];
        NSString *issueKey = [commentDict valueForKey:@"issueKey"];
        JMCDLog(@"Comment inserted for JIRA %@ and marked as sent: %@", issueKey, requestId);
        comment.requestId = requestId;
        [store insertComment:comment forIssue:issueKey];
        [comment release];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kJMCNewCommentCreated object:nil]];
    }
}

- (void)transportDidFinishWithError:(NSError*)error statusCode:(int)status requestId:(NSString*)requestId
{
    // if the status code is 404, the issue has been deleted where this reply was attempted. alert the user? - add a comment
    if (status == 404)
    {
        // TODO: potentially create a new feedback instead of leaving a reply ? UX maybe tricky..
        JMCQueueItem *item = [[JMCRequestQueue sharedInstance] getItem:requestId];
        JMCComment *comment = [[JMCComment alloc] initWithAuthor:@"jmc"
                                                      systemUser:NO
                                                            body:JMCLocalizedString(@"JMCDeletedIssueMessage", @"This issue has been deleted. Please create new feedback instead.")
                                                            date:[NSDate date]
                                                            requestId:requestId];
        [[JMCIssueStore instance] insertComment:comment forIssue:item.originalIssueKey];
        [comment release];
        [[JMCRequestQueue sharedInstance] deleteItem:requestId];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kJMCNewCommentCreated object:nil]];
    }


}

#pragma end 

@end
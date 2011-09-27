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
    // update comment in db as sent!
    [[JMCIssueStore instance] markCommentAsSent:requestId];
}

- (void)transportDidFinishWithError:(NSError *)error requestId:(NSString *)requestId
{
 
}

#pragma end 

@end
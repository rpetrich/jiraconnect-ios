//
//  Created by niick on 26/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCOfflineReplyDelegate.h"
#import "JMCIssueStore.h"
#import "JMCRequestQueue.h"
#import "JMCQueueItem.h"
#import "JMC.h"

@implementation JMCOfflineReplyDelegate

-(void)transportDidFinish:(NSString *) response requestId:(NSString*)requestId
{
    JMCQueueItem *item = [[JMCRequestQueue sharedInstance] getItem:requestId];
    NSLog(@"Got item with issue key: %@, %@", requestId, item.originalIssueKey);
    [[JMCIssueStore instance] insertCommentFromJSON:response forIssueKey:item.originalIssueKey];

    // anounce that a comment was added, so the Replies View can redraw
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kJMCNewCommentCreated object:nil]];
}

- (void)transportDidFinishWithError:(NSError*)error requestId:(NSString*)requestId
{
    NSLog(@"Offline Reply Did Finish with ERROR: %@, %@", [error description], requestId);
}

@end
//
//  Created by nick on 20/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>
#import "JMCQueueItem.h"


enum {
    JMCSentStatusNew = 0, // request is newly queued
    JMCSentStatusSuccess = 1,   // request success
    JMCSentStatusRetry = 2,     // request in a temporary error - will be retried
    JMCSentStatusPermError = 3  // request in a permanent error - will not be retried
};
typedef int JMCSentStatus;

/**
* The request queue is used for storing and later forwarding of any feedback
* that can not be sent due to lack of network.
* When an item is added to the queue, it is stored to disk.
* When it is deleted from the queue (after a successful send attempt) it is deleted from disk.
*/
@interface JMCRequestQueue : NSObject {

}

+(JMCRequestQueue*) sharedInstance;

-(void) flushQueue;

-(void) addItem:(JMCQueueItem *)item;
- (NSMutableDictionary *)getQueueList;
-(JMCQueueItem *) getItem:(NSString *)uuid;
-(void) deleteItem:(NSString*)uuid;

@end
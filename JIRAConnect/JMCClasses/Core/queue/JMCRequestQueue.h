//
//  Created by nick on 20/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>
#import "JMCQueueItem.h"

/**
* The request queue is used for storing and later forwarding of any feedback
* that can not be sent due to lack of network.
* When an item is added to the queue, it is stored to disk.
* When it is deleted from the queue (after a successful send attempt) it is deleted from disk.
*/
@interface JMCRequestQueue : NSObject {

}

+(JMCRequestQueue*) sharedInstance;

-(void) addItem:(JMCQueueItem *)item;
- (NSMutableArray *)getQueueList;
-(JMCQueueItem *) getItem:(NSString *)uuid;
-(void) deleteItem:(NSString*)uuid;

@end
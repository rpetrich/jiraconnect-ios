//
//  Created by nick on 20/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCRequestQueue.h"
#import "JMCAttachmentItem.h"

@interface JMCRequestQueue ()
- (NSString *)getQueueIndexPath;

- (NSString *)getQueueDirPath;

- (NSString *)getQueueItemPathFor:(NSString *)uuid;


- (void)saveQueueIndex:(NSMutableArray *)queueList;

@end

@implementation JMCRequestQueue {

}

+ (JMCRequestQueue *)sharedInstance
{
    static JMCRequestQueue *instance = nil;
    if (instance == nil) {
        instance = [[JMCRequestQueue alloc] init];
        NSLog(@"queue at  %@", [instance getQueueIndexPath]);

    }
    return instance;
}

- (void)addItem:(JMCQueueItem *)item
{
    NSMutableArray *queueIndex = [self getQueueList];
    [queueIndex addObject:item.uuid];
    [self saveQueueIndex:queueIndex];
    // now save the queue item to disc...
    NSString *itemPath = [self getQueueItemPathFor:item.uuid];
    [item writeToFile:itemPath];
}

-(JMCQueueItem *)getItem:(NSString *)uuid
{
    NSString *itemPath = [self getQueueItemPathFor:uuid];
    return [JMCQueueItem queueItemFromFile:itemPath];
}


- (void)saveQueueIndex:(NSMutableArray *)queueList
{
    [queueList writeToFile:[self getQueueIndexPath] atomically:YES];
}

- (void)deleteItem:(NSString *)uuid {
    NSMutableArray *queue = [self getQueueList];
    u_int index = [queue indexOfObject:uuid];
    if (index < [queue count]) {
        [queue removeObjectAtIndex:index];
    }
    [self saveQueueIndex:queue];
    // now remove the queue item from disk
    [[NSFileManager defaultManager] removeItemAtPath:[self getQueueItemPathFor:uuid] error:nil];

}


// This is the actual list of items that need sending
- (NSMutableArray *)getQueueList {
    NSMutableArray *queueIndex = [[[NSArray arrayWithContentsOfFile:[self getQueueIndexPath]] mutableCopy] autorelease];
    if (queueIndex == nil) {
        queueIndex = [NSMutableArray arrayWithCapacity:0];
    }
    return queueIndex;
}

// The path of the plist that stores a list of request that need resending
- (NSString *)getQueueIndexPath {
    return [[self getQueueDirPath] stringByAppendingPathComponent:@"JMCQueueIndex.plist"];
}

- (NSString *)getQueueItemPathFor:(NSString *)uuid {
    return [[self getQueueDirPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", uuid]];
}

- (NSString *)getQueueDirPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cache = [paths objectAtIndex:0];
    NSString *cachePath = [cache stringByAppendingPathComponent:@"JMC"];

    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return cachePath;
}

@end
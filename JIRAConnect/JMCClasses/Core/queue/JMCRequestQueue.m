//
//  Created by nick on 20/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCRequestQueue.h"
#import "JMCAttachmentItem.h"
#import "JMCIssueTransport.h"
#import "JMCReplyTransport.h"
#import "JMCCreateIssueDelegate.h"
#import "JMCReplyDelegate.h"

static NSOperationQueue *sharedOperationQueue = nil;

@interface JMCRequestQueue ()
- (NSString *)getQueueIndexPath;

- (NSString *)getQueueDirPath;

- (NSString *)getQueueItemPathFor:(NSString *)uuid;

- (void)saveQueueIndex:(NSMutableArray *)queueList;

@end

JMCIssueTransport* _issueTransport;
JMCReplyTransport* _replyTransport;
NSRecursiveLock* _flushLock;

@implementation JMCRequestQueue {

}

+ (JMCRequestQueue *)sharedInstance
{
    static JMCRequestQueue *instance = nil;
    if (instance == nil) {
        instance = [[JMCRequestQueue alloc] init];
        sharedOperationQueue = [[NSOperationQueue alloc] init];
        [sharedOperationQueue setMaxConcurrentOperationCount:1];
        _issueTransport = [[JMCIssueTransport alloc] init];
        _replyTransport = [[JMCReplyTransport alloc] init];
        _issueTransport.delegate = [[[JMCCreateIssueDelegate alloc]init] autorelease];
        _replyTransport.delegate = [[[JMCReplyDelegate alloc] init] autorelease];
        _flushLock = [[NSRecursiveLock alloc] init];
        NSLog(@"queue at  %@", [instance getQueueIndexPath]);

    }
    return instance;
}

-(void) flushQueue
{
    @synchronized (_flushLock) { // Ensure a single thread at a time tries to flush the queue.
        JMCRequestQueue *requestQueue = [JMCRequestQueue sharedInstance];
        NSArray *items = [requestQueue getQueueList];
        for (NSString *itemId in items) {
            JMCQueueItem *item = [requestQueue getItem:itemId];
            NSOperation *operation = nil;
            if ([item.type isEqualToString:kTypeReply]) {
                operation = [_replyTransport requestFromItem:item];
            } else if ([item.type isEqualToString:kTypeCreate]) {
                operation = [_issueTransport requestFromItem:item];
            }
            if (operation == nil) {
                NSLog(@"Missing or invalid queued item with id: %@. Removing from queue.", itemId);
                [requestQueue deleteItem:itemId];
            } else {
                [sharedOperationQueue addOperation:operation];
                NSLog(@"Added request to operation queue %@", item.uuid);
            }
        }
    }
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

-(void) dealloc
{
    [_issueTransport release];
    [_replyTransport release];
    [sharedOperationQueue release];
    [_flushLock release];
    [super dealloc];
}

@end
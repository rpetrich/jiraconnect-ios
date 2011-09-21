//
//  Created by nick on 20/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCRequestQueue.h"


@interface JMCRequestQueue()
-(NSString *) getQueueIndexPath;
-(NSString *) getQueueDirPath;
-(NSMutableArray *) getQueueList;
-(void) saveQueueIndex:(NSMutableArray *)queueList;

@end

@implementation JMCRequestQueue
{

}

+(JMCRequestQueue*) sharedInstance
{
    static JMCRequestQueue* instance = nil;
    if (instance == nil) {
        instance = [[JMCRequestQueue alloc] init];
    }
    return instance;
}

-(void)addItem:(JMCQueueItem *)item
{
    NSMutableArray* queueIndex = [self getQueueList];
    [queueIndex addObject:item.uuid];
    [self saveQueueIndex:queueIndex];
    
}

- (void)saveQueueIndex:(NSMutableArray *)queueList
{
    NSLog(@"Saving Queue index to = %@", [self getQueueIndexPath]);

    [queueList writeToFile:[self getQueueIndexPath] atomically:YES];
}

-(void)deleteItem:(NSString*)uuid
{
    
}

-(NSArray *)getAllItems
{
    NSArray* queueIndex = [self getQueueList];
    for (NSString * uuid in queueIndex) {
        NSLog(@"UUID: %@", uuid);
    }
}

// This is the actual list of items that need sending
-(NSMutableArray*) getQueueList
{
    NSMutableArray *queueIndex = [[[NSArray arrayWithContentsOfFile:[self getQueueIndexPath]] mutableCopy] autorelease];
    if (queueIndex == nil) {
        queueIndex = [NSMutableArray arrayWithCapacity:0];
    }
    return queueIndex;
}

// The path of the plist that stores a list of request that need resending
-(NSString *) getQueueIndexPath
{
    return [[self getQueueDirPath] stringByAppendingPathComponent:@"JMCQueueIndex.plist"];
}

-(NSString *)getQueueDirPath
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cache = [paths objectAtIndex:0];
	NSString *cachePath = [cache stringByAppendingPathComponent:@"JMC"];

	if (![fileManager fileExistsAtPath:cachePath])
		[fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];

	return cachePath;
}

-(NSString *) getQueueColophonPathFor:(NSString*)queueId
{
    return [[self getQueueDirPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"jmc-%@.plist", queueId]];
}

@end
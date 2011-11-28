//
//  Created by nick on 20/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCQueueItem.h"

#define kUuid @"itemUuid"
#define kUrl @"itemUrl"
#define kAttachments @"attachments"
#define kOriginalIssueKey @"originalIssueKey"

#define kType @"type"

#define kTypeCreate @"CREATE"
#define kTypeReply @"REPLY"

@implementation JMCQueueItem
{

}

// generate a UUID for this request
+(NSString*) generateUniqueId {
    NSString *queueItemId = nil;
    CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
    if (theUUID) {
        NSString *uuid = NSMakeCollectable(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
        CFRelease(theUUID);
        queueItemId = [NSString stringWithFormat:@"jmc-%@", uuid];
        CFRelease(uuid);
    }
    return queueItemId; // what when nil?
}

-(id)initWith:(NSString*)uuid type:(NSString*)type attachments:(NSArray*)attachments issueKey:(NSString *)originalIssueKey
{
    if ((self = [super init])) {
        self.uuid = uuid;
        self.type = type;
        self.attachments = attachments;
        self.originalIssueKey = originalIssueKey;
    }
    return self;
}

+ (JMCQueueItem *)queueItemFromFile:(NSString*)filepath
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
}


- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:self.uuid forKey:kUuid];
    [coder encodeObject:self.type forKey:kType];
    [coder encodeObject:self.attachments forKey:kAttachments];
    [coder encodeObject:self.originalIssueKey forKey:kOriginalIssueKey];
}

- (id)initWithCoder:(NSCoder*)coder {

    self = [super init];
    if (!self) return nil;

    NSString* tmpUuid = [coder decodeObjectForKey:kUuid];
    self.uuid = tmpUuid;
    self.attachments = [coder decodeObjectForKey:kAttachments];
    self.originalIssueKey = [coder decodeObjectForKey:kOriginalIssueKey];
    self.type = [coder decodeObjectForKey:kType];
    
    return self;
}

-(void)writeToFile:(NSString *)filepath
{
    [NSKeyedArchiver archiveRootObject:self toFile:filepath];
}

@synthesize uuid=_uuid, type=_type, attachments=_attachments, originalIssueKey=_originalIssueKey;

- (void) dealloc
{
    self.uuid = nil;
    self.type = nil;
    self.attachments = nil;
    self.originalIssueKey = nil;
    [super dealloc];
}
@end
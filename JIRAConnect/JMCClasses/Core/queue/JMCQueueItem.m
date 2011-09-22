//
//  Created by nick on 20/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCQueueItem.h"

#define kUuid @"itemUuid"
#define kUrl @"itemUrl"
#define kParameters @"parameters"
#define kAttachments @"attachments"

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

-(id)initWith:(NSString*)uuid url:(NSString*)url parameters:(NSDictionary*) params attachments:(NSArray*)attachments
{
    if ((self = [super init])) {
        self.uuid = uuid;
        self.url = url;
        self.parameters = params;
        self.attachments = attachments;
    }
    return self;
}

+ (JMCQueueItem *)queueItemFromFile:(NSString*)filepath
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
}


- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:self.uuid forKey:kUuid];
    [coder encodeObject:self.url forKey:kUrl];
    [coder encodeObject:self.parameters forKey:kParameters];
    [coder encodeObject:self.attachments forKey:kAttachments];
}

- (id)initWithCoder:(NSCoder*)coder {

    self = [super init];
    if (!self) return nil;

    self.uuid = [coder decodeObjectForKey:kUuid];
    self.url = [coder decodeObjectForKey:kUrl];
    self.attachments = [coder decodeObjectForKey:kAttachments];
    self.parameters = [coder decodeObjectForKey:kParameters];
    
    return self;
}

-(void)writeToFile:(NSString *)filepath
{
    [NSKeyedArchiver archiveRootObject:self toFile:filepath];
}

@synthesize uuid=_uuid, url=_url, parameters=_parameters, attachments=_attachments;

- (void) dealloc
{
    self.uuid = nil;
    self.url = nil;
    self.parameters = nil;
    self.attachments = nil;
    [super dealloc];
}
@end
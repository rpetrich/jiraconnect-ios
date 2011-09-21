//
//  Created by nick on 20/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCQueueItem.h"


@implementation JMCQueueItem
{

}

// generate a UUID for this request
-(NSString*) generateUniqueId {
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
-(void)write
{

}
-(void)read
{
    
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
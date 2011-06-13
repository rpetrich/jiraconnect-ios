//
//  Created by nick on 22/05/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JCOAttachmentItem.h"


@implementation JCOAttachmentItem

@synthesize filenameFormat;
@synthesize contentType;
@synthesize data;
@synthesize name;
@synthesize type;


- (id)initWithName:(NSString *)aName data:(NSData *)aData type:(JCOAttachmentType)aType contentType:(NSString *)aContentType filenameFormat:(NSString *)aFilenameFormat {
    self = [super init];
    if (self) {
        contentType = [aContentType retain];
        data = [aData retain];
        filenameFormat = [aFilenameFormat retain];
        name = [aName retain];
        type = aType;

    }
    return self;
}

- (void)dealloc {
    [filenameFormat release];
    [contentType release];
    [data release];
    [name release];
    [super dealloc];
}
@end
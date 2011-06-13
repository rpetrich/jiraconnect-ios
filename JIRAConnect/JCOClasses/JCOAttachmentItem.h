//
//  Created by nick on 22/05/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>

typedef enum {
  JCOAttachmentTypeRecording,
  JCOAttachmentTypeImage
} JCOAttachmentType;

@interface JCOAttachmentItem: NSObject {
    NSString* name;
    NSString*filenameFormat;
    NSString* contentType;
    JCOAttachmentType type;
    NSData* data;
}
@property(nonatomic, retain) NSString *contentType;
@property(nonatomic, retain) NSData *data;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *filenameFormat;
@property(nonatomic) JCOAttachmentType type;

- (id)initWithName:(NSString *)aName data:(NSData *)aData type:(JCOAttachmentType)aType contentType:(NSString *)aContentType filenameFormat:(NSString *)aFilenameFormat;


@end
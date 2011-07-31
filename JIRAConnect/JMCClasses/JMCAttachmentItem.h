/**
   Copyright 2011 Atlassian Software

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
**/
//
//  Created by nick on 22/05/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>

typedef enum {
    JMCAttachmentTypeRecording,
    JMCAttachmentTypeImage
} JMCAttachmentType;

@interface JMCAttachmentItem : NSObject {
    NSString* name;
    NSString*filenameFormat;
    NSString* contentType;
    JMCAttachmentType type;
    NSData* data;
}
@property(nonatomic, retain) NSString *contentType;
@property(nonatomic, retain) NSData *data;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *filenameFormat;
@property(nonatomic) JMCAttachmentType type;

- (id)initWithName:(NSString *)aName data:(NSData *)aData type:(JMCAttachmentType)aType contentType:(NSString *)aContentType filenameFormat:(NSString *)aFilenameFormat;


@end
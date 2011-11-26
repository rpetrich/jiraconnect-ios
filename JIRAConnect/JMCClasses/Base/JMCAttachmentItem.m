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


#import "JMCAttachmentItem.h"

#define kFilenameFormat @"filenameFormat"
#define kContentType @"contentType"
#define kData @"data"
#define kName @"name"
#define kType @"type"

@implementation JMCAttachmentItem

@synthesize filenameFormat;
@synthesize contentType;
@synthesize data;
@synthesize name;
@synthesize type;
@synthesize thumbnail;


- (id)initWithName:(NSString *)aName
              data:(NSData *)aData
              type:(JMCAttachmentType)aType
       contentType:(NSString *)aContentType
    filenameFormat:(NSString *)aFilenameFormat {
    self = [super init];
    if (self) {
        contentType = [aContentType retain];
        data = [aData retain];
        filenameFormat = [aFilenameFormat retain];
        name = [aName retain];
        type = aType;
        thumbnail = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    
    [coder encodeObject:self.data forKey:kData];
    [coder encodeObject:self.contentType forKey:kContentType];
    [coder encodeObject:self.filenameFormat forKey:kFilenameFormat];
    [coder encodeObject:self.name forKey:kName];
    [coder encodeInt:self.type forKey:kType];
}

- (id)initWithCoder:(NSCoder*)coder {
    self = [super init];
    if (!self) return nil;
    
    self.data = [coder decodeObjectForKey:kData];
    self.contentType = [coder decodeObjectForKey:kContentType];
    self.filenameFormat = [coder decodeObjectForKey:kFilenameFormat];
    self.name = [coder decodeObjectForKey:kName];
    self.type = [coder decodeIntForKey:kType];

    return self;
}


- (void)dealloc {
    [thumbnail release], thumbnail = nil;
    [filenameFormat release], filenameFormat = nil;
    [contentType release], contentType = nil;
    [data release], data = nil;
    [name release], name = nil;
    [super dealloc];
}
@end
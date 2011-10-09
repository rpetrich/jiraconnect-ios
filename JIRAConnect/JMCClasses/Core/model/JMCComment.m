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

#import "JMCComment.h"


@implementation JMCComment

@synthesize requestId = _requestId, author = _author, systemUser = _systemUser, body = _body, date = _date, dateLong;

- (void)dealloc {
    self.author = nil;
    self.body = nil;
    self.date = nil;
    self.requestId = nil;
    [super dealloc];
}

- (id) initWithAuthor:(NSString *)p_author
           systemUser:(BOOL)p_sys
                 body:(NSString *)p_body
                 date:(NSDate *)p_date
            requestId:(NSString *)requestId
{
    if ((self = [super init])) {
        self.author = p_author;
        self.body = p_body;
        self.date = p_date;
        self.systemUser = p_sys;
        self.requestId = requestId;
    }
    return self;
}

+ (NSNumber *)dateToMillisSince1970:(NSDate *)date {
    return [NSNumber numberWithDouble:[date timeIntervalSince1970] * 1000];
}

+ (NSDate *)dateFromMillisSince1970:(NSNumber *)number {
    return [NSDate dateWithTimeIntervalSince1970:[number longLongValue] / 1000];
}

- (NSNumber *)dateLong {
    return [JMCComment dateToMillisSince1970:self.date];
}


+ (JMCComment *)newCommentFromDict:(NSDictionary *)data {
    // FMDB will lowercase all column names, so take a copy and lowercase the keys
    NSMutableDictionary *lowerMap = [[NSMutableDictionary alloc] initWithCapacity:[data count]];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [lowerMap setObject:obj forKey:[key lowercaseString]];
    }];

    NSString *author = [lowerMap objectForKey:@"username"];
    if (!author) {
        author = @"(no author)";
    }
    NSString *body = [lowerMap objectForKey:@"text"];
    if (!body) {
        body = @"(no body)";
    }
    NSNumber *msSinceEpoch = [lowerMap objectForKey:@"date"];
    NSDate *date = [JMCComment dateFromMillisSince1970:msSinceEpoch];
    NSNumber *systemUser = (NSNumber *) [lowerMap objectForKey:@"systemuser"];

    NSString *uuid = (NSString *) [lowerMap objectForKey:@"uuid"]; // this matches the uuid column in the database
    [lowerMap release];

    return [[JMCComment alloc] initWithAuthor:author systemUser:systemUser.boolValue body:body date:date requestId:uuid];
}

@end

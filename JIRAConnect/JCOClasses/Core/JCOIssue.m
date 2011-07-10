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

#import "JCOIssue.h"

@implementation JCOIssue

@synthesize key = _key, status = _status, title = _title, description = _description,
            comments = _comments, hasUpdates = _hasUpdates, dateUpdated = _dateUpdated,
            dateCreated = _dateCreated, dateCreatedLong, dateUpdatedLong;

- (void) dealloc {
    self.key, self.status, self.title, self.description, self.comments, self.dateUpdated = nil;
    self.dateCreated = nil;
    [super dealloc];
}

- (JCOComment *) latestComment {
    return [self.comments count] > 0 ? ((JCOComment *)[self.comments lastObject]) : nil;
}

- (NSNumber *)dateToMillisSince1970:(NSDate*) date
{
    return [NSNumber numberWithDouble:[date timeIntervalSince1970] * 1000];
}

-(NSDate *) dateFromMillisSince1970:(NSNumber *)number
{
    return [NSDate dateWithTimeIntervalSince1970:[number longLongValue] / 1000];
}

- (NSNumber *) dateUpdatedLong
{
    return [self dateToMillisSince1970:self.dateUpdated];
}

- (NSNumber *) dateCreatedLong
{
    return [self dateToMillisSince1970:self.dateCreated];
}

- (void)addCommentsFrom:(NSArray *)commentDataArray
{
    if (commentDataArray)
        {
            NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:[commentDataArray count]];
            for (NSDictionary* data in commentDataArray)
            {
                NSString* author = [data objectForKey:@"username"];
                if (!author)
                {
                    author = @"(no author)";
                }
                NSString* body = [data objectForKey:@"text"];
                if (!body)
                {
                    body = @"(no body)";
                }
                NSNumber* msSinceEpoch = [data objectForKey:@"date"];
                NSDate* date =  [self dateFromMillisSince1970:msSinceEpoch];
                NSNumber* value = (NSNumber*)[data objectForKey:@"systemUser"];
                JCOComment * comment = [[JCOComment alloc] initWithAuthor:author systemUser:[value boolValue] body:body date:date];
                [array addObject:comment];
                [comment release];
            }
            self.comments = array;
            [array release];
        }
}

- (id) initWithDictionary:(NSDictionary*)map
{

    // FMDB will lowercase all column names, so take a copy and lowercase the keys

    NSMutableDictionary *lowerMap = [[NSMutableDictionary alloc] initWithCapacity:[map count]];
    [map enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [lowerMap setObject:obj forKey:[key lowercaseString]];
    }];
    if ((self = [super init])) {
		self.key = [lowerMap objectForKey:@"key"];
        self.status = [lowerMap objectForKey:@"status"];
        self.title = [lowerMap objectForKey:@"title"];
        self.description = [lowerMap objectForKey:@"description"];
        NSNumber* hasUpdatesNum = [lowerMap objectForKey:@"hasupdates"];
        self.hasUpdates = [hasUpdatesNum boolValue];

        NSNumber *created = [lowerMap objectForKey:@"datecreated"];
        NSNumber *updated = [lowerMap objectForKey:@"dateupdated"];
        self.dateCreated = [self dateFromMillisSince1970:created];
        self.dateUpdated = [self dateFromMillisSince1970:updated];
        
        if (!self.key)
        {
            self.key = @"(no issue key)";
        }
        if (!self.status)
        {
            self.status = @"(no status)";
        }
        if (!self.title)
        {
            self.title = @"(no title)";
        }
        if (!self.description)
        {
            self.description = @"(no description)";
        }
    }
    [lowerMap release];
	return self;
}

@end

//
//  JCOIssue.m
//  JiraConnect
//
//  Created by Shihab Hamid on 17/03/11.
//

#import "JCOIssue.h"

@implementation JCOIssue

@synthesize key = _key, status = _status, title = _title, description = _description,
            comments = _comments, hasUpdates = _hasUpdates, lastUpdated = _lastUpdated;

- (void) dealloc {
    self.key, self.status, self.title, self.description, self.comments, self.lastUpdated= nil;
	[super dealloc];
}

- (JCOComment *) latestComment {
    return [self.comments count] > 0 ? ((JCOComment *)[self.comments lastObject]) : nil;
}

- (id) initWithDictionary:(NSDictionary*)map {
	if ((self = [super init])) {
		self.key = [map objectForKey:@"key"];
        self.status = [map objectForKey:@"status"];
        self.title = [map objectForKey:@"title"];
        self.description = [map objectForKey:@"description"];
        NSNumber* msLastUpdated = [map objectForKey:@"lastUpdated"];
        self.lastUpdated = [NSDate dateWithTimeIntervalSince1970:[msLastUpdated longLongValue]/1000];
        
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
        
        NSArray* commentDataArray = [map objectForKey:@"comments"];
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
                NSDate* date = [NSDate dateWithTimeIntervalSince1970:[msSinceEpoch longLongValue]/1000];
                NSNumber* value = (NSNumber*)[data objectForKey:@"systemUser"];
                JCOComment * comment = [[JCOComment alloc] initWithAuthor:author systemUser:[value boolValue] body:body date:date];
                [array addObject:comment];
                [comment release];
            }
            self.comments = array;
            [array release];
        }
    }
    
    NSLog(@"\t received issue  %@, %@", self.key, self.title);
    
	return self;
}

@end

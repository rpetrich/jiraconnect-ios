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

#import "JCOIssueStore.h"
#import "JCOIssue.h"
#import "JCOComment.h"
#import "FMDatabase.h"
#import "JSON.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation JCOIssueStore

FMDatabase *db;
NSString* _jcoDbPath;

+(JCOIssueStore *) instance {
	static JCOIssueStore *singleton = nil;
	
	if (singleton == nil) {
        _jcoDbPath = [[NSString stringWithFormat:@"%@/issues.db", DOCUMENTS_FOLDER] retain];
		singleton = [[JCOIssueStore alloc] init];
	}
	return singleton;
}

- (id) init {
	if ((self = [super init])) {
        // db init code...
        db = [FMDatabase databaseWithPath:_jcoDbPath];
        [db retain];
        // create schema

        [db open]; // TODO: check return value, and throw exception if false.

        NSLog(@"JCO databasePath = %@", _jcoDbPath);
        [db executeUpdate:@"CREATE table if not exists ISSUE "
                            "(id INTEGER PRIMARY KEY ASC autoincrement, "
                            "key TEXT, "
                            "status TEXT, "
                            "title TEXT, "
                            "description TEXT, "
                            "dateCreated INTEGER, "
                            "dateUpdated INTEGER, "
                            "hasUpdates  INTEGER, "
                            "comments TEXT)"];

    }
	return self;
}

- (JCOIssue *) initIssueAtIndex:(NSUInteger)index {
    // each column must match the JSON field JIRA returns for an issue entity
    FMResultSet *res = [db executeQuery:
                               @"SELECT "
                                   "key, "
                                   "title, "
                                   "description, "
                                   "dateUpdated, "
                                   "dateCreated, "
                                   "hasUpdates "
                                "FROM issue ORDER BY dateUpdated desc LIMIT 1 OFFSET ?",
                           [NSNumber numberWithUnsignedInt:index]];
    if ([res next]) {
        NSDictionary *dictionary = [res resultDict];
        return [[JCOIssue alloc] initWithDictionary:dictionary];
    }
    NSLog(@"No issue at index = %lu", index);
    return nil;
}

-(NSArray*) loadCommentsFor:(JCOIssue*) issue {

    FMResultSet *res = [db executeQuery:
                               @"SELECT "
                                   "comments "
                                "FROM issue WHERE key = ?",
                           issue.key];
    if ([res next]) {
        return [[res stringForColumn:@"comments"] JSONValue];
    }
    NSLog(@"No Comments for issue %@", issue.key);
    return nil;

}

-(BOOL) issueExists:(JCOIssue *)issue {
    FMResultSet *res = [db executeQuery:@"SELECT key FROM issue WHERE key = ?", issue.key];
    return [res next];
}

-(void) updateIssue:(JCOIssue *)issue  withComments:(NSString *)commentJSON {
    // update an issue whenever the comments change. set comments and dateUpdated
    [db executeUpdate:
        @"UPDATE issue "
         "SET status = ?, dateUpdated = ?, hasUpdates = ?, comments = ? "
         "WHERE key = ?",
        issue.status, issue.dateUpdatedLong, [NSNumber numberWithBool:issue.hasUpdates], commentJSON, issue.key];

}

-(void) insertIssue:(JCOIssue *)issue withComments:(NSString *)commentJSON {
    [db executeUpdate:
        @"INSERT INTO ISSUE "
                "(key, status, title, description, dateCreated, dateUpdated, hasUpdates, comments) "
                "VALUES "
                "(?,?,?,?,?,?,?,?) ",
        issue.key, issue.status, issue.title, issue.description, issue.dateCreatedLong, issue.dateUpdatedLong,
        [NSNumber numberWithBool:issue.hasUpdates], commentJSON];

    // TODO: handle error err...
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

-(void) insertOrUpdateIssue:(JCOIssue *)issue withComments:(NSString *)commentJSON {

    if ([self issueExists:issue]) {
        [self updateIssue:issue withComments:commentJSON];
    } else {
        [self insertIssue:issue withComments:commentJSON];
    }
}

- (void) updateWithData:(NSDictionary*)data {

    NSArray* issues = [data objectForKey:@"issuesWithComments"];
    int numNewIssues = 0;
    [db beginTransaction];
    for (NSDictionary* dict in issues)
    {
        JCOIssue * issue = [[JCOIssue alloc] initWithDictionary:dict];
        if (issue.hasUpdates) {
            numNewIssues++;
        }
        NSString* commentJSON = [[dict objectForKey:@"comments"] JSONRepresentation];
        [self insertOrUpdateIssue:issue withComments:commentJSON];
        [issue release];
    }
    [db commit];

    self.newIssueCount = numNewIssues;
    self.count = [issues count];

}

@synthesize newIssueCount = _newIssueCount, count = _count;

- (void) dealloc {
    [db release];
	[super dealloc];
}

@end

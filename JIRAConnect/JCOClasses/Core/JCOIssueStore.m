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
        // create schema, preserving existing
        [self createSchema:NO];
        [db open]; // TODO: check return value, and throw exception if false.
        NSLog(@"JCO databasePath = %@", _jcoDbPath);
    }
	return self;
}

-(void) createSchema:(BOOL)dropExisting
{
// for now - always get all the data from JIRA. store it in the local db.
    if (dropExisting) {
        [db executeUpdate:@"DROP table if exists ISSUE"];
        [db executeUpdate:@"DROP table if exists COMMENT"];
    }
    [db executeUpdate:@"CREATE table if not exists ISSUE "
                        "(id INTEGER PRIMARY KEY ASC autoincrement, "
                        "key TEXT, "
                        "status TEXT, "
                        "title TEXT, "
                        "description TEXT, "
                        "dateCreated INTEGER, "
                        "dateUpdated INTEGER, "
                        "dateDeleted INTEGER, "
                        "hasUpdates  INTEGER, "
                        "comments TEXT)"];


    [db executeUpdate:@"CREATE table if not exists COMMENT "
                        "(id INTEGER PRIMARY KEY ASC autoincrement, "
                        "issuekey TEXT, "
                        "username TEXT, "
                        "systemuser INTEGER, "
                        "text TEXT, "
                        "date INTEGER) "];
}

- (JCOIssue *) initIssueAtIndex:(NSUInteger)issueIndex {
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
                           [NSNumber numberWithUnsignedInt:issueIndex]];
    if ([res next]) {
        NSDictionary *dictionary = [res resultDict];
        return [[JCOIssue alloc] initWithDictionary:dictionary];
    }
    NSLog(@"No issue at index = %lu", issueIndex);
    return nil;
}

- (NSMutableArray*) loadCommentsFor:(JCOIssue*) issue {

    FMResultSet *res = [db executeQuery:
                               @"SELECT "
                                   "* "
                                "FROM comment WHERE issuekey = ?",
                           issue.key];
    NSMutableArray *comments = [NSMutableArray arrayWithCapacity:1];

    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    while ([res next]) {
        // a comment entity is the following JSON:
        // {"username":"jiraconnectuser","systemUser":true,"text":"testing","date":1310840213824}
        JCOComment *comment = [JCOComment newCommentFromDict:[res resultDict]];
        [comments addObject:comment];
        [comment release];
    }
    return comments;
}

- (void) insertComment:(JCOComment *)comment forIssue:(JCOIssue *)issue {

    [db executeUpdate:
        @"INSERT INTO COMMENT "
                "(issuekey, username, systemuser, text, date) "
                "VALUES "
                "(?,?,?,?,?) ",
        issue.key, comment.author, [NSNumber numberWithBool:comment.systemUser], comment.body, comment.dateLong];

    // TODO: handle error err...
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }

}

-(BOOL) issueExists:(JCOIssue *)issue {
    FMResultSet *res = [db executeQuery:@"SELECT key FROM issue WHERE key = ?", issue.key];
    return [res next];
}

-(void) updateIssue:(JCOIssue *)issue {
    // update an issue whenever the comments change. set comments and dateUpdated
    [db executeUpdate:
        @"UPDATE issue "
         "SET status = ?, dateUpdated = ?, hasUpdates = ? "
         "WHERE key = ?",
        issue.status, issue.dateUpdatedLong, [NSNumber numberWithBool:issue.hasUpdates], issue.key];

}

-(void) insertIssue:(JCOIssue *)issue {
    [db executeUpdate:
        @"INSERT INTO ISSUE "
                "(key, status, title, description, dateCreated, dateUpdated, hasUpdates) "
                "VALUES "
                "(?,?,?,?,?,?,?) ",
        issue.key, issue.status, issue.title, issue.description, issue.dateCreatedLong, issue.dateUpdatedLong,
        [NSNumber numberWithBool:issue.hasUpdates]];

    // TODO: handle error err...
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

-(void) markAsRead:(JCOIssue *)issue {
    [db executeUpdate:
            @"UPDATE issue "
             "SET hasUpdates = 0 "
             "WHERE key = ?", issue.key];
    issue.hasUpdates = NO;
}

-(void) insertOrUpdateIssue:(JCOIssue *)issue {

    if ([self issueExists:issue]) {
        [self updateIssue:issue];
    } else {
        [self insertIssue:issue];
    }
}

-(int) count {
    FMResultSet *res = [db executeQuery:
                        @"SELECT "
                        "count(*) as count from ISSUE"];
    [res next];
    NSNumber* count = (NSNumber*)[res objectForColumnName:@"count"];
    return [count intValue];
}

-(int)newIssueCount {
    FMResultSet *res = [db executeQuery:
                        @"SELECT "
                        "count(*) from ISSUE where hasUpdates = 1"];
    [res next];
    NSNumber* countNum = (NSNumber*)[res objectForColumnIndex:0];
    return [countNum intValue];
}

- (void) updateWithData:(NSDictionary*)data {

    NSArray* issues = [data objectForKey:@"issuesWithComments"];

    // no issues are sent when there are no updates.
    if (!issues || [issues count] == 0) {
        // so no need to create the schema
        return;
    }
    // when there is an update - the database gets re-populated
    [self createSchema:YES];
    int numNewIssues = 0;
    [db beginTransaction];
    for (NSDictionary* dict in issues)
    {
        JCOIssue * issue = [[JCOIssue alloc] initWithDictionary:dict];
        if (issue.hasUpdates) {
            numNewIssues++;
        }
        [self insertOrUpdateIssue:issue];

        NSArray* comments = [dict objectForKey:@"comments"];
        // insert each comment
        for (NSDictionary *commentDict in comments) {
            JCOComment *jcoComment = [JCOComment newCommentFromDict:commentDict];
            [self insertComment:jcoComment forIssue:issue];
            [jcoComment release];
        }

        [issue release];
    }
    [db commit];
}

@synthesize newIssueCount, count;

- (void) dealloc {
    [db release];
	[super dealloc];
}

@end

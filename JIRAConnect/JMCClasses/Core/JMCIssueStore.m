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

#import "JMCIssueStore.h"
#import "JMCIssue.h"
#import "JMCComment.h"
#import "FMDatabase.h"
#import "JSON.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation JMCIssueStore

FMDatabase *db;
NSString* _jcoDbPath;

+(JMCIssueStore *) instance {
    static JMCIssueStore *singleton = nil;
    
    if (singleton == nil) {
        _jcoDbPath = [[NSString stringWithFormat:@"%@/issues.db", DOCUMENTS_FOLDER] retain];
        NSLog(@"DB AT = %@", _jcoDbPath);
        
                singleton = [[JMCIssueStore alloc] init];
    }
    return singleton;
}

- (id) init {
    if ((self = [super init])) {
        // db init code...
        db = [FMDatabase databaseWithPath:_jcoDbPath];
        [db setLogsErrors:YES];
        [db retain];
        if (![db open]) {
            NSLog(@"Error opening database for JMC. Issue Inbox will be unavailable.");
            return nil;
        }
        // create schema, preserving existing
        [self createSchema:NO];
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
                        "uuid TEXT, " // a handle to manage unsent issues by
                        "sent INTEGER, " // if the issue was sent successfully or not
                        "key TEXT, "
                        "status TEXT, "
                        "summary TEXT, "
                        "description TEXT, "
                        "dateCreated INTEGER, "
                        "dateUpdated INTEGER, "
                        "dateDeleted INTEGER, "
                        "hasUpdates  INTEGER)"];


    [db executeUpdate:@"CREATE table if not exists COMMENT "
                        "(id INTEGER PRIMARY KEY ASC autoincrement, "
                        "uuid TEXT, " // a handle to manage unsent comments by
                        "sent INTEGER, " // if the comment was sent successfully or not
                        "issuekey TEXT, "
                        "username TEXT, "
                        "systemuser INTEGER, "
                        "text TEXT, "
                        "date INTEGER) "];
}


- (JMCComment*) newLastCommentFor:(JMCIssue *) issue {

    FMResultSet *res = [db executeQuery:
                               @"SELECT "
                                   "* "
                                "FROM comment WHERE issuekey = ? order by date desc limit 1",
                           issue.key];

    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return nil;
    }
    if ([res next]) {
        NSDictionary* resultDict = [res resultDict];
        return [JMCComment newCommentFromDict:resultDict];
    }
    return nil;
}

- (JMCIssue *) newIssueAtIndex:(NSUInteger)issueIndex {
    // each column must match the JSON field JIRA returns for an issue entity
    FMResultSet *res = [db executeQuery:
                               @"SELECT "
                                   "uuid, "
                                   "sent, "
                                   "key, "
                                   "summary, "
                                   "description, "
                                   "dateUpdated, "
                                   "dateCreated, "
                                   "hasUpdates "
                                "FROM issue ORDER BY dateUpdated desc LIMIT 1 OFFSET ?",
                           [NSNumber numberWithUnsignedInt:issueIndex]];
    if ([res next]) {
        NSDictionary* dictionary = [res resultDict];
        JMCIssue* issue = [[JMCIssue alloc] initWithDictionary:dictionary];
        JMCComment* lastComment = [self newLastCommentFor:issue];
        if (lastComment) {
            issue.comments = [NSMutableArray arrayWithObject:lastComment];
        }
        [lastComment release];
        return issue;
    }
    NSLog(@"No issue at index = %u", issueIndex);
    return nil;
}

- (NSMutableArray*) loadCommentsFor:(JMCIssue *) issue {

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
        // {"username":"jiraconnectuser","systemUser":true,"text":"testing","date":1310840213824, "uuid":"uniquestring"}
        JMCComment *comment = [JMCComment newCommentFromDict:[res resultDict]];
        [comments addObject:comment];
        [comment release];
    }
    return comments;
}

-(void) insertCommentFromJSON:(NSString *)json forIssueKey:(NSString *)key
{
    NSDictionary *commentDict = [json JSONValue];
    // lower case
    JMCComment *comment = [JMCComment newCommentFromDict:commentDict];
    [self insertComment:comment forIssue:key];
    [comment release];
}

- (void) insertComment:(JMCComment *)comment forIssue:(NSString *)issueKey {

    [db executeUpdate:
        @"INSERT INTO COMMENT "
                "(issuekey, username, systemuser, text, date, uuid, sent) "
                "VALUES "
                "(?,?,?,?,?,?,?) ",
                issueKey, comment.author, [NSNumber numberWithBool:comment.systemUser], comment.body, comment.dateLong, comment.uuid,
                [NSNumber numberWithBool:comment.sent]];

    // TODO: handle error err...
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }

}

-(BOOL) issueExists:(JMCIssue *)issue {
    FMResultSet *res = [db executeQuery:@"SELECT key FROM issue WHERE key = ?", issue.key];
    return [res next];
}

-(void) updateIssue:(JMCIssue *)issue {
    // update an issue whenever the comments change. set comments and dateUpdated
    [db executeUpdate:
        @"UPDATE issue "
         "SET status = ?, dateUpdated = ?, hasUpdates = ?, uuid = ? "
         "WHERE key = ?",
        issue.status, issue.dateUpdatedLong, [NSNumber numberWithBool:issue.hasUpdates], issue.uuid, issue.key];

}

-(void) insertIssue:(JMCIssue *)issue {
    [db executeUpdate:
        @"INSERT INTO ISSUE "
                "(key, uuid, status, summary, description, dateCreated, dateUpdated, hasUpdates, sent) "
                "VALUES "
                "(?,?,?,?,?,?,?,?,?) ",
        issue.key, issue.uuid, issue.status, issue.summary, issue.description, issue.dateCreatedLong, issue.dateUpdatedLong,
        [NSNumber numberWithBool:issue.hasUpdates], [NSNumber numberWithBool:issue.sent]];

    // TODO: handle error err...
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

- (void) markIssueAsSent:(NSString *)requestId
{
    [db executeUpdate:
            @"UPDATE issue "
             "SET sent = 1 "
             "WHERE uuid = ?", requestId];
}

- (void) markCommentAsSent:(NSString *)requestId
{
    [db executeUpdate:
            @"UPDATE comment "
             "SET sent = 1 "
             "WHERE uuid = ?", requestId];
}

-(void) markAsRead:(JMCIssue *)issue {
    [db executeUpdate:
            @"UPDATE issue "
             "SET hasUpdates = 0 "
             "WHERE key = ?", issue.key];
    issue.hasUpdates = NO;
}

-(void) updateIssueByUUID:(JMCIssue *)issue {
    // update an issue whenever the comments change. set comments and dateUpdated
        [db executeUpdate:
            @"UPDATE issue "
             "SET status = ?, dateUpdated = ?, hasUpdates = ?, key = ?"
             "WHERE uuid = ?",
            issue.status, issue.dateUpdatedLong, [NSNumber numberWithBool:issue.hasUpdates], issue.key, issue.uuid];
}

-(void) insertOrUpdateIssue:(JMCIssue *)issue {

    if ([self issueExists:issue]) {
        NSLog(@"UPDATING issue = %@", issue);

        [self updateIssue:issue];
    } else {
        NSLog(@"INSERTING issue = %@", issue);
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

-(int) newIssueCount {
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
    @synchronized (self) {
        [self createSchema:YES];
        int numNewIssues = 0;
        [db beginTransaction];
        for (NSDictionary *dict in issues) {
            JMCIssue *issue = [[JMCIssue alloc] initWithDictionary:dict];
            if (issue.hasUpdates) {
                numNewIssues++;
            }
            [self insertOrUpdateIssue:issue];

            NSArray *comments = [dict objectForKey:@"comments"];
            // insert each comment
            for (NSDictionary *commentDict in comments) {
                JMCComment *jcoComment = [JMCComment newCommentFromDict:commentDict];
                [self insertComment:jcoComment forIssue:issue.key];
                [jcoComment release];
            }

            [issue release];
        }
        [db commit];
    }

}

@synthesize newIssueCount, count;

- (void) dealloc {
    [db release];
    [super dealloc];
}

@end

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
#import "JMCDatabase.h"
#import "JMCMacros.h"
#import "JMC.h"

@implementation JMCIssueStore

JMCDatabase *db;
NSString* _jcoDbPath;
static NSRecursiveLock *writeLock;


+(JMCIssueStore *) instance {
    static JMCIssueStore *singleton = nil;
    if (singleton == nil) {
        NSString* jmcDbPath = [[JMC instance] dataDirPath];
        _jcoDbPath = [[NSString stringWithFormat:@"%@/issues.db", jmcDbPath] retain];
        singleton = [[JMCIssueStore alloc] init];
        writeLock = [[NSRecursiveLock alloc] init];
    }
    return singleton;
}

- (id) init {
    if ((self = [super init])) {
        // db init code...
        db = [JMCDatabase databaseWithPath:_jcoDbPath];
        [db setLogsErrors:YES];
        [db retain];
        if (![db open]) {
            JMCALog(@"Error opening database for JMC. Issue Inbox will be unavailable.");
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
                        "issuekey TEXT, "
                        "username TEXT, "
                        "systemuser INTEGER, "
                        "text TEXT, "
                        "date INTEGER) "];
}


- (JMCComment*) newLastCommentFor:(JMCIssue *) issue {

    JMCResultSet *res = [db executeQuery:
                               @"SELECT "
                                   "* "
                                "FROM comment WHERE issuekey = ? order by date desc limit 1",
                           issue.key];

    if ([db hadError]) {
        JMCALog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
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
    JMCResultSet *res = [db executeQuery:
                               @"SELECT "
                                   "uuid, "
                                   "key, "
                                   "summary, "
                                   "description, "
                                   "dateUpdated, "
                                   "dateCreated, "
                                   "hasUpdates "
                                "FROM issue ORDER BY hasUpdates desc, dateUpdated desc LIMIT 1 OFFSET ?",
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
    JMCALog(@"No issue at index = %u", issueIndex);
    return nil;
}

- (NSMutableArray*) loadCommentsFor:(JMCIssue *) issue {

    JMCResultSet *res = [db executeQuery:
                               @"SELECT "
                                   "* "
                                "FROM comment WHERE issuekey = ?",
                           issue.key];
    NSMutableArray *comments = [NSMutableArray arrayWithCapacity:1];

    if ([db hadError]) {
        JMCALog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
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

- (void) insertComment:(JMCComment *)comment forIssue:(NSString *)issueKey {

    @synchronized (writeLock) {
        NSString* body = comment.body.length > 0 ? comment.body : JMCLocalizedString(@"No Comment", @"No Comment");
        [db executeUpdate:
         @"INSERT INTO COMMENT "
         "(issuekey, username, systemuser, text, date, uuid) "
         "VALUES "
         "(?,?,?,?,?,?) ",
         issueKey, comment.author, [NSNumber numberWithBool:comment.systemUser], body, comment.dateLong, comment.requestId];
    }
    // TODO: handle error err...
    if ([db hadError]) {
        JMCALog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }

}

-(BOOL) issueExists:(JMCIssue *)issue {
    JMCResultSet *res = [db executeQuery:@"SELECT key FROM issue WHERE key = ?", issue.key];
    return [res next];
}

-(void) updateIssue:(JMCIssue *)issue {
    // update an issue whenever the comments change. set comments and dateUpdated
    @synchronized (writeLock) {
    [db executeUpdate:
        @"UPDATE issue "
         "SET status = ?, dateUpdated = ?, hasUpdates = ?, uuid = ? "
         "WHERE key = ?",
        issue.status, issue.dateUpdatedLong,
                    [NSNumber numberWithBool:issue.hasUpdates], issue.requestId, issue.key];
    }

}

-(void) insertIssue:(JMCIssue *)issue {
    @synchronized (writeLock) {
        NSString* description = issue.description.length > 0 ? issue.description : JMCLocalizedString(@"No Description", @"No description");
        NSString* summary = issue.summary.length > 0 ? issue.summary : JMCLocalizedString(@"No Description", @"No description");
        [db executeUpdate:
         @"INSERT INTO ISSUE "
         "(key, uuid, status, summary, description, dateCreated, dateUpdated, hasUpdates) "
         "VALUES "
         "(?,?,?,?,?,?,?,?) ",
         issue.key, issue.requestId, issue.status, summary, description, issue.dateCreatedLong, issue.dateUpdatedLong,
         [NSNumber numberWithBool:issue.hasUpdates]];
    }
    // TODO: handle error err...
    if ([db hadError]) {
        JMCALog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

-(void) markAsRead:(JMCIssue *)issue {
    @synchronized (writeLock) {
        [db executeUpdate:
                @"UPDATE issue "
                        "SET hasUpdates = 0 "
                        "WHERE key = ?", issue.key];
        issue.hasUpdates = NO;
    }
}

-(void) updateIssueByUUID:(JMCIssue *)issue {
    // update an issue whenever the comments change. set comments and dateUpdated
    @synchronized (writeLock) {
        [db executeUpdate:
                @"UPDATE issue "
                        "SET status = ?, dateUpdated = ?, hasUpdates = ?, key = ? "
                        "WHERE uuid = ?",
                issue.status, issue.dateUpdatedLong,
                        [NSNumber numberWithBool:issue.hasUpdates], issue.key, issue.requestId];
    }
}

- (BOOL) issueExistsIssueByUUID:(NSString *)uuid
{
    JMCResultSet *res = [db executeQuery:@"SELECT id FROM issue WHERE uuid = ?", uuid];
    return [res next];

}
- (BOOL) commentExistsIssueByUUID:(NSString *)uuid
{
    JMCResultSet *res = [db executeQuery:@"SELECT id FROM comment WHERE uuid = ?", uuid];
    return [res next];
}

-(void) insertOrUpdateIssue:(JMCIssue *)issue {

    @synchronized (writeLock) {
        if ([self issueExists:issue]) {
            [self updateIssue:issue];
        } else {
            [self insertIssue:issue];
        }
    }
}

-(int) count {
    JMCResultSet *res = [db executeQuery:
                        @"SELECT "
                        "count(*) as count from ISSUE"];
    [res next];
    NSNumber* count = (NSNumber*)[res objectForColumnName:@"count"];
    return [count intValue];
}

-(int) newIssueCount {
    JMCResultSet *res = [db executeQuery:
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
    @synchronized (writeLock) {
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

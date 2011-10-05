//
//  Created by nick on 5/10/11.
//
//  To change this template use File | Settings | File Templates.
//

#import "ModelTests.h"
#import "JMCIssue.h"
#import "JSON.h"

@implementation ModelTests

- (void)assertIssueProps:(NSNumber *)timestamp issue:(JMCIssue *)issue {
    STAssertEqualObjects(@"somerandomuuid", issue.requestId, @"Request ID is not set");
    STAssertEqualObjects(@"NERDS-123", issue.key, @"Key not set");
    STAssertEqualObjects(@"Open", issue.status, @"status not set");
    STAssertEqualObjects(@"This is an issue description", issue.description, @"summary missing");
    STAssertEqualObjects(@"This is an issue title", issue.summary, @"title missing");
    STAssertEqualObjects(timestamp, issue.dateCreatedLong, @"date created missing");
    STAssertEqualObjects(timestamp, issue.dateUpdatedLong, @"date updated missing");
    STAssertEquals(NO, issue.hasUpdates, @"Incorrect has updates status");
}
-(void)testIssue
{

    NSNumber *timestamp = [NSNumber numberWithLong:1317789000];
    NSDictionary *issueDict = [NSDictionary
            dictionaryWithObjectsAndKeys:@"NERDS-123",                    @"key",
                                         @"a-random-request-id",          @"uuid",
                                         @"Open",                         @"status",
                                         @"This is an issue description", @"description",
                                         @"This is an issue title",       @"title",
                                            timestamp,                    @"datecreated",
                                            timestamp,                    @"dateupdated",
                                         NO,                              @"hasupdates",
                                         nil];
    JMCIssue *issue = [JMCIssue issueWith:[issueDict JSONRepresentation] requestId:@"somerandomuuid"];
    [self assertIssueProps:timestamp issue:issue];
    issue = [[JMCIssue alloc] initWithDictionary:issueDict];
    STAssertEqualObjects(@"a-random-request-id", issue.requestId, @"uuid not read from map");
}

-(void)testComment
{
    NSNumber *timestamp = [NSNumber numberWithLong:1317789000];
    NSDictionary *dict = [NSDictionary
            dictionaryWithObjectsAndKeys:@"Comment Reporter",               @"username",
                                         @"The actual body of the comment", @"text",
                                         timestamp,                         @"date",
                                         @"a-random-request-id",            @"uuid",
                                         nil];
    JMCComment *comment = [JMCComment newCommentFromDict:dict];
    
    STAssertEqualObjects(@"a-random-request-id", comment.requestId, @"uuid not read from map");
    STAssertEqualObjects(@"Comment Reporter", comment.author, @"username not read from map");
    STAssertEqualObjects(@"The actual body of the comment", comment.body, @"comment body not read from map");
    STAssertEqualObjects(@"a-random-request-id", comment.requestId, @"uuid not read from map");
    STAssertEqualObjects(timestamp, comment.dateLong, @"date not read from map");

}



@end
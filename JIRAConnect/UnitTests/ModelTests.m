//
//  Created by nick on 5/10/11.
//
//  To change this template use File | Settings | File Templates.
//

#import "ModelTests.h"
#import "JMCIssue.h"
#import "JSON.h"

@implementation ModelTests

-(void)testIssue
{
    NSDate *date1 = [NSDate date];
    NSDictionary *issueDict = [NSDictionary
            dictionaryWithObjectsAndKeys:@"uuidvalue", @"uuid",
                                         @"NERDS-123", @"key",
                                         @"Open", @"status",
                                         @"This is an issue description", @"summary",
                                         @"This is an issue title", @"title",
                                         NO, @"hasupdates",
                                         date1, @"datecreated",
                                         date1, @"dateupdate",
                                        nil];
    JMCIssue *issue = [JMCIssue issueWith:[issueDict JSONRepresentation] requestId:@"somerandomuuid"];
    STAssertEqualObjects(@"NERDS-123", issue.key, @"Key missing");
}

@end
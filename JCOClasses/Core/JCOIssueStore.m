    //
//  JCOIssueStore.m
//  JiraConnect
//
//  Created by Shihab Hamid on 17/03/11.
//

#import "JCOIssueStore.h"
#import "JCOIssue.h"

@implementation JCOIssueStore


+(JCOIssueStore *) instance {
	static JCOIssueStore *singleton = nil;
	
	if (singleton == nil) {
		singleton = [[JCOIssueStore alloc] init];
	}
	return singleton;
}

- (id) init {
	if ((self = [super init])) {
        self.issues = [NSArray array];
	}
	return self;
}

- (void) updateWithData:(NSDictionary*)data {    
    NSArray* updated = [data objectForKey:@"updatedIssuesWithComments"];
    // here only for testing!
//    NSArray* updated = [data objectForKey:@"oldIssuesWithComments"];
    NSArray* old = [data objectForKey:@"oldIssuesWithComments"];
    
    NSMutableArray* tempOld = [[NSMutableArray alloc] initWithCapacity:[old count] + [updated count]];
    
    for (NSDictionary* dict in updated)
    {
        JCOIssue * issue = [[JCOIssue alloc] initWithDictionary:dict];

        issue.hasUpdates = YES;
        [tempOld addObject:issue];
        [issue release];
    }
    
    for (NSDictionary* dict in old)
    {
        JCOIssue * issue = [[JCOIssue alloc] initWithDictionary:dict];
        [tempOld addObject:issue];
        [issue release];
    }
    
    self.issues = tempOld;
    self.newIssueCount = [updated count];
    
    [tempOld release];    
}

@synthesize issues = _issues, newIssueCount = _newIssueCount;

- (void) dealloc {
    self.issues = nil;
	[super dealloc];
}



@end

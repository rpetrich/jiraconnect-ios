//
//  JCIssueStore.m
//  JiraConnect
//
//  Created by Shihab Hamid on 17/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import "JCIssueStore.h"
#import "JCIssue.h"

@implementation JCIssueStore

@synthesize oldIssues = _oldIssues;

+(JCIssueStore*) instance {
	static JCIssueStore *singleton = nil;
	
	if (singleton == nil) {
		singleton = [[JCIssueStore alloc] init];
	}
	return singleton;
}

- (void) dealloc {
    [_oldIssues release];
	[super dealloc];
}

- (id) init {
	if ((self = [super init])) {
        self.oldIssues = [NSArray array];
	}
	return self;
}

- (void) updateWithData:(NSDictionary*)data {    
    NSArray* updated = [data objectForKey:@"updatedIssuesWithComments"];
    NSArray* old = [data objectForKey:@"oldIssuesWithComments"];
    
    NSMutableArray* tempOld = [[NSMutableArray alloc] initWithCapacity:[old count] + [updated count]];
    
    for (NSDictionary* dict in updated)
    {
        JCIssue* issue = [[JCIssue alloc] initWithDictionary:dict];

        issue.hasUpdates = YES;
        NSLog(@"HAS UPDATES!");
        [tempOld addObject:issue];
        [issue release];
    }
    
    for (NSDictionary* dict in old)
    {
        JCIssue* issue = [[JCIssue alloc] initWithDictionary:dict];
        [tempOld addObject:issue];
        [issue release];
    }
    
    self.oldIssues = tempOld;
    
    [tempOld release];    
}


@end

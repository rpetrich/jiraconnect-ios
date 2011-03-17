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

@synthesize updatedIssues = _updatedIssues;
@synthesize oldIssues = _oldIssues;

+(JCIssueStore*) instance {
	static JCIssueStore *singleton = nil;
	
	if (singleton == nil) {
		singleton = [[JCIssueStore alloc] init];
	}
	return singleton;
}

- (void) dealloc {
	[_updatedIssues release];
    [_oldIssues release];
	[super dealloc];
}

- (id) init {
	if ((self = [super init])) {
        self.updatedIssues = [NSArray array];
        self.oldIssues = [NSArray array];
	}
	return self;
}

- (void) updateWithData:(NSDictionary*)data {    
    NSArray* updated = [data objectForKey:@"updatedIssuesWithComments"];
    NSArray* old = [data objectForKey:@"oldIssuesWithComments"];
    
    NSMutableArray* tempUpdated = [[NSMutableArray alloc] initWithCapacity:[updated count]];
    NSMutableArray* tempOld = [[NSMutableArray alloc] initWithCapacity:[old count]];
    
    for (NSDictionary* dict in updated)
    {
        JCIssue* issue = [[JCIssue alloc] initWithDictionary:dict];
        [tempUpdated addObject:tempUpdated];
        [issue release];
    }
    
    for (NSDictionary* dict in old)
    {
        JCIssue* issue = [[JCIssue alloc] initWithDictionary:dict];
        [tempOld addObject:tempUpdated];
        [issue release];
    }
    
    self.updatedIssues = tempUpdated;
    self.oldIssues = tempOld;
    
    [tempUpdated release];
    [tempOld release];    
}


@end

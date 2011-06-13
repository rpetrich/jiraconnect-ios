/**
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
*/


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

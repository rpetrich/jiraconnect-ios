//
//  JCIssueStore.h
//  JiraConnect
//
//  Created by Shihab Hamid on 17/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JCIssueStore : NSObject {
    // array of JCIssues 
    NSArray* _issues;
    int _newIssueCount;
}

@property (nonatomic, retain) NSArray* issues;
@property (assign, nonatomic) int newIssueCount;


- (void) updateWithData:(NSDictionary*)data;
+ (JCIssueStore*) instance;

@end

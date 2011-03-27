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
    NSArray* _oldIssues;
}

@property (nonatomic, retain) NSArray* oldIssues;

- (void) updateWithData:(NSDictionary*)data;
+ (JCIssueStore*) instance;

@end

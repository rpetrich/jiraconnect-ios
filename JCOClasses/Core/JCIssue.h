//
//  JCIssue.h
//  JiraConnect
//
//  Created by Shihab Hamid on 17/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JCIssue : NSObject {
    NSString* _key;
    NSString* _status;
    NSString* _title;
    NSString* _description;
    NSArray* _comments;
}

@property (nonatomic, retain) NSString* key;
@property (nonatomic, retain) NSString* status;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSArray* comments;

- (id) initWithDictionary:(NSDictionary*)map;

@end

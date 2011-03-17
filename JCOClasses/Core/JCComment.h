//
//  JCComment.h
//  JiraConnect
//
//  Created by Shihab Hamid on 17/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JCComment : NSObject {
    NSString* _author;
    NSString* _body;
}

@property (nonatomic, retain) NSString* author;
@property (nonatomic, retain) NSString* body;

@end

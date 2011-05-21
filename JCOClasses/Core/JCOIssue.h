//
//  JCOIssue.h
//  JiraConnect
//
//  Created by Shihab Hamid on 17/03/11.
//

#import <Foundation/Foundation.h>
#import "JCOComment.h"


@interface JCOIssue : NSObject {
    NSString* _key;
    NSString* _status;
    NSString* _title;
    NSString* _description;
    NSDate* _lastUpdated;
    NSDate* _created;
    NSMutableArray* _comments;
    BOOL _hasUpdates;
}

@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, retain) NSDate* lastUpdated;
@property (nonatomic, retain) NSString* key;
@property (nonatomic, retain) NSString* status;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSMutableArray* comments;
@property (nonatomic, assign) BOOL hasUpdates;

- (id) initWithDictionary:(NSDictionary*)map;
- (JCOComment *) latestComment;

@end

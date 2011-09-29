/**
   Copyright 2011 Atlassian Software

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
**/

#import <Foundation/Foundation.h>
#import "JMCComment.h"


@interface JMCIssue : NSObject {
    NSString*_requestId;
    NSString* _key;
    NSString* _status;
    NSString* _summary;
    NSString* _description;
    NSDate* _dateUpdated;
    NSDate* _dateCreated;
    NSMutableArray* _comments;
    BOOL _hasUpdates;
}

@property (nonatomic, retain) NSDate* dateCreated;
@property (nonatomic, retain) NSDate* dateUpdated;
@property (nonatomic, assign) NSNumber* dateUpdatedLong;
@property (nonatomic, assign) NSNumber* dateCreatedLong;
@property (nonatomic, retain) NSString* requestId;
@property (nonatomic, retain) NSString* key;
@property (nonatomic, retain) NSString* status;
@property (nonatomic, retain) NSString* summary;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSMutableArray* comments;
@property (nonatomic, assign) BOOL hasUpdates;

- (id) initWithDictionary:(NSDictionary*)map;
- (JMCComment *) latestComment;

+(JMCIssue *)issueWith:(NSString*)issueJSON requestId:(NSString*)uuid;

@end

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

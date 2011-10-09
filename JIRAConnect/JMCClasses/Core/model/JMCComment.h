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


@interface JMCComment : NSObject {
    NSString*_requestId;
    NSString* _author;
    BOOL _systemUser;
    NSString* _body;
    NSDate* _date;
}

@property (nonatomic, retain) NSString* requestId;
@property (nonatomic, retain) NSString* author;
@property (nonatomic, assign) BOOL systemUser;
@property (nonatomic, retain) NSString* body;
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, assign) NSNumber* dateLong;

- (id) initWithAuthor:(NSString *)p_author systemUser:(BOOL)p_sys body:(NSString *)p_body date:(NSDate *)p_date requestId:(NSString *)requestId;
+ (JMCComment *) newCommentFromDict:(NSDictionary *)data;

@end

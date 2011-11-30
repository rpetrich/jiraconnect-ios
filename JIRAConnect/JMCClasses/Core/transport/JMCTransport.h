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
#import "JMCIssue.h"
#import "JMCQueueItem.h"

@class JMCTransportOperation;

#define kJMCTransportCreateIssuePath   @"rest/jconnect/%@/issue/create?%@"
#define kJMCTransportCreateCommentPath @"rest/jconnect/%@/issue/comment/%@?%@"
#define kJMCTransportNotificationsPath @"rest/jconnect/%@/issue/updates?%@"

#define kJMCHeaderNameRequestId @"-x-jmc-requestid"

@protocol JMCTransportDelegate <NSObject>

- (void)transportWillSend:(NSString *)entityJSON requestId:(NSString *)requestId issueKey:(NSString *)issueKey;
- (void)transportDidFinish:(NSString *)response requestId:(NSString*)requestId;

@optional

- (void)transportDidFinishWithError:(NSError*)error statusCode:(int)status requestId:(NSString*)requestId;

@end

@protocol JMCQueueItemDelegate <NSObject>
- (NSString *) getType;
- (NSString *) getIssueKey;
- (NSURL *) makeUrlFor:(NSString *)issueKey;
@end

@interface JMCTransport : NSObject <UIAlertViewDelegate, JMCQueueItemDelegate> 
{
    @private
    id <JMCTransportDelegate> _delegate;
}

@property(nonatomic, retain) id <JMCTransportDelegate> delegate;

- (JMCTransportOperation *) requestFromItem:(JMCQueueItem *)item;

- (JMCQueueItem *)qeueItemWith:(NSString *)description
                   attachments:(NSArray *)attachments
                        params:(NSMutableDictionary *)params
                      issueKey:(NSString *)issueKey;
- (void)sayThankYou;

- (NSMutableDictionary*)buildCommonParams:(NSString*)subject type:(NSString*)typeName;

+ (NSString *)encodeCommonParameters;
+ (NSMutableString *)encodeParameters:(NSDictionary *)parameters;

+ (NSString *)buildJSONString:(id)object;
+ (id)parseJSONString:(NSString *)jsonString;

@end

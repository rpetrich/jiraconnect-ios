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
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JCOIssue.h"

#define kJCOTransportCreateIssuePath   @"rest/jconnect/latest/issue/create?%@"
#define kJCOTransportCreateCommentPath @"rest/jconnect/latest/issue/comment/%@"
#define kJCOTransportNotificationsPath @"rest/jconnect/latest/issue/updates?%@"

@protocol JCOTransportDelegate <NSObject>

- (void)transportDidFinish;

@optional
- (void)transportDidFinishWithError:(NSError*)error;

@end


@interface JCOTransport : NSObject <UIAlertViewDelegate> {
    id <JCOTransportDelegate> _delegate;
}

@property(nonatomic, retain) id <JCOTransportDelegate> delegate;

- (void)populateCommonFields:(NSString *)description images:(NSArray *)attachments payloadData:(NSDictionary *)payloadData customFields:(NSDictionary *)customFields upRequest:(ASIFormDataRequest *)upRequest params:(NSMutableDictionary *)params;

- (void)requestFailed:(ASIHTTPRequest *)request;

+ (NSMutableString *)encodeParameters:(NSDictionary *)parameters;


@end

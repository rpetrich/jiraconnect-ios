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
//
//  Created by nick on 13/05/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCTransport.h"
#import "JMCCrashTransport.h"
#import "JMC.h"
#import "JMCAttachmentItem.h"
#import "JMCRequestQueue.h"

@implementation JMCCrashTransport

- (NSURL *)makeUrlFor:(NSString *)issueKey
{
    NSString *queryString = [JMCTransport encodeCommonParameters];
    NSString *path = [NSString stringWithFormat:kJMCTransportCreateIssuePath, [[JMC sharedInstance] getAPIVersion], queryString];
    return [NSURL URLWithString:path relativeToURL:[JMC sharedInstance].url];
}

- (NSString *) getType {
    return kTypeCreate;
}

- (void)addCustomFieldsTo:(NSMutableArray *)attachments
{
    // add all custom fields as one attachment item
    NSMutableDictionary *customFields = [[JMC sharedInstance] getCustomFields];
    if ([customFields count] > 0) 
    {
        NSData *customFieldsJSON = [[JMCTransport buildJSONString:customFields] dataUsingEncoding:NSUTF8StringEncoding];
        
        JMCAttachmentItem *customFieldsItem = [[JMCAttachmentItem alloc] initWithName:@"customfields"
                                                                                 data:customFieldsJSON
                                                                                 type:JMCAttachmentTypeCustom
                                                                          contentType:@"application/json"
                                                                       filenameFormat:@"customfields.json"];
        [attachments addObject:customFieldsItem];
        [customFieldsItem release];
    }
}

- (void)addCrashData:(NSString *)crashReport to:(NSMutableArray *)attachments
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    // TODO: use the actual crash date for this file extension
    // TODO: sanitize AppName for spaces, puntuation, etc..
    NSString *filename =
    [[[JMC sharedInstance] getAppName] stringByAppendingFormat:@"-%@.crash", [dateFormatter stringFromDate:[NSDate date]]];
    [dateFormatter release];
    NSData *rawData = [crashReport dataUsingEncoding:NSUTF8StringEncoding];
    JMCAttachmentItem *crashData = [[JMCAttachmentItem alloc] initWithName:filename
                                                                      data:rawData
                                                                      type:JMCAttachmentTypeCustom
                                                               contentType:@"text/plain"
                                                            filenameFormat:filename];
    
    [attachments addObject:crashData];
    [crashData release];
}

-(void)addCustomAttachmentTo:(NSMutableArray*)attachments
{
    if ([[JMC sharedInstance].customDataSource respondsToSelector:@selector(customAttachment)]) {
        JMCAttachmentItem *payloadData = [[JMC sharedInstance].customDataSource customAttachment];
        if (payloadData) {
            [attachments addObject:payloadData];
        }
    }
}

- (void)send:(NSString *)subject description:(NSString *)description crashReport:(NSString *)crashReport
{
        
    NSString *typeName = [[JMC sharedInstance] issueTypeNameFor:JMCIssueTypeCrash useDefault:@"Crash"];
    NSMutableDictionary *params = [self buildCommonParams:subject type:typeName];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"isCrash"];
    NSMutableArray* attachments = [NSMutableArray arrayWithCapacity:3];

    [self addCustomFieldsTo:attachments];
    [self addCrashData:crashReport to:attachments];    
    [self addCustomAttachmentTo:attachments];
    
    JMCQueueItem *item = [self qeueItemWith:description attachments:attachments params:params issueKey:nil];
    [[JMCRequestQueue sharedInstance] addItem:item];
}

@end
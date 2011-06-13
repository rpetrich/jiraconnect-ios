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


#import "JCOIssueTransport.h"
#import "JCO.h"

@interface JCOIssueTransport()
@property(nonatomic, retain) ASIFormDataRequest *createIssueRequest;
@end

@implementation JCOIssueTransport

@synthesize createIssueRequest;

- (void)send:(NSString *)subject description:(NSString *)description images:(NSArray *)images payload:(NSDictionary *)payloadData fields:(NSDictionary *)customFields {

    // issue creation url is:
    // curl -u admin:admin -F media=@image.png "http://localhost:2990/jira/rest/jconnect/latest/issue/create?project=<projectname>"
    NSDictionary *queryParams = [NSDictionary dictionaryWithObject:[[JCO instance] getProject] forKey:@"project"];
    NSString *queryString = [JCOTransport encodeParameters:queryParams];
    NSString *urlPath = [NSString stringWithFormat:kJCOTransportCreateIssuePath, queryString];
    NSURL *url = [NSURL URLWithString:urlPath
                        relativeToURL:[JCO instance].url];

    NSLog(@"Sending feedback to:    %@", url.absoluteString);
    ASIFormDataRequest *upRequest = [ASIFormDataRequest requestWithURL:url];
    [self setCreateIssueRequest:upRequest];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (subject) {
        [params setObject:subject forKey:@"summary"];
    }

    [self populateCommonFields:description images:images payloadData:payloadData customFields:customFields upRequest:upRequest params:params];
    [upRequest setDelegate:self];
    [upRequest setShouldAttemptPersistentConnection:NO];
    [upRequest setTimeOutSeconds:15];
    [upRequest startAsynchronous];
}

-(void) cancel {
    [[self createIssueRequest] cancel];
}

#pragma mark UIAlertViewDelelgate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}


-(void) dealloc {
    [createIssueRequest release];
    [super dealloc];
}

@end
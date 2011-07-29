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


#import "JMCIssueTransport.h"
#import "JMC.h"

@interface JMCIssueTransport ()
@property(nonatomic, retain) ASIFormDataRequest *createIssueRequest;
@end

@implementation JMCIssueTransport

@synthesize createIssueRequest;

- (void)send:(NSString *)subject description:(NSString *)description images:(NSArray *)images payload:(NSDictionary *)payloadData fields:(NSDictionary *)customFields {

    // issue creation url is:
    // curl -u admin:admin -F media=@image.png "http://localhost:2990/jira/rest/jconnect/latest/issue/create?project=<projectname>"
    NSDictionary *queryParams = [NSDictionary dictionaryWithObject:[[JMC instance] getProject] forKey:@"project"];
    NSString *queryString = [JMCTransport encodeParameters:queryParams];
    NSString *urlPath = [NSString stringWithFormat:kJCOTransportCreateIssuePath, queryString];
    NSURL *url = [NSURL URLWithString:urlPath
                        relativeToURL:[JMC instance].url];

    NSLog(@"Sending feedback to:    %@", url.absoluteString);
    ASIFormDataRequest *upRequest = [ASIFormDataRequest requestWithURL:url];
    [self setCreateIssueRequest:upRequest];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (subject) {
        [params setObject:subject forKey:@"summary"];
    }
    NSString *typeName = [[JMC instance] issueTypeNameFor:JCOIssueTypeFeedback useDefault:@"Bug"];
    [params setObject:typeName forKey:@"type"];
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
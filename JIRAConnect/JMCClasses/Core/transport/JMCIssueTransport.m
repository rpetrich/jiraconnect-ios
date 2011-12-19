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
#import "JMCRequestQueue.h"

@interface JMCIssueTransport ()
@property(nonatomic, retain) NSURLRequest *createIssueRequest;
@end

@implementation JMCIssueTransport

@synthesize createIssueRequest;

- (NSURL *)makeUrlFor:(NSString *)issueKey
{
    // issue creation url is:
    // curl -u admin:admin -F media=@image.png "http://localhost:2990/jira/rest/jconnect/latest/issue/create?project=<projectname>"
    NSString *queryString = [JMCTransport encodeCommonParameters];
    NSString *urlPath = [NSString stringWithFormat:kJMCTransportCreateIssuePath, [[JMC sharedInstance] getAPIVersion], queryString];
    return [NSURL URLWithString:urlPath relativeToURL:[JMC sharedInstance].url];
}

-(NSString *) getType {
    return kTypeCreate;
}


- (void)send:(NSString *)subject
 description:(NSString *)description
 attachments:(NSArray *)attachments {

    NSString *typeName = [[JMC sharedInstance] issueTypeNameFor:JMCIssueTypeFeedback useDefault:@"Bug"];
    NSMutableDictionary* params = [self buildCommonParams:subject type:typeName];

    JMCQueueItem *queueItem = [self qeueItemWith:description
                                     attachments:attachments
                                          params:params
                                        issueKey:nil];
    
    [[JMCRequestQueue sharedInstance] addItem:queueItem];
    [[JMC sharedInstance] flushRequestQueue];

    [self sayThankYou];
}

-(void) dealloc {
    [createIssueRequest release];
    [super dealloc];
}

@end
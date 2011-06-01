//
//  Created by nick on 28/04/11.
//
//  To change this template use File | Settings | File Templates.
//


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
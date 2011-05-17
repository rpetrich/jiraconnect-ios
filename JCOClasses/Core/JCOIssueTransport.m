//
//  Created by nick on 28/04/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JCOIssueTransport.h"
#import "JCO.h"


@implementation JCOIssueTransport

- (void)send:(NSString *)subject
        description:(NSString *)description
        screenshot:(UIImage *)screenshot
        voiceData:(NSData *)voiceData
        payload:(NSDictionary *)payloadData
        fields:(NSDictionary *)customFields {

    // issue creation url is:
    // curl -u admin:admin -F media=@image.png "http://localhost:2990/jira/rest/jconnect/latest/issue/<projectname>"

    NSString *path = [@"rest/jconnect/latest/issue/" stringByAppendingString:[[JCO instance] getProjectName]];
    NSURL *url = [NSURL URLWithString:path relativeToURL:[JCO instance].url];
    NSLog(@"Sending feedback to... %@", url);

    ASIFormDataRequest *upRequest = [ASIFormDataRequest requestWithURL:url];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (subject) {
        [params setObject:subject forKey:@"summary"];
    }
    [self populateCommonFields:description screenshot:screenshot voiceData:voiceData payloadData:payloadData customFields:customFields upRequest:upRequest params:params];
    [upRequest setDelegate:self];
    [upRequest setShouldAttemptPersistentConnection:NO];
    [upRequest setTimeOutSeconds:15];
    [upRequest startAsynchronous];
}

#pragma mark UIAlertViewDelelgate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"ISSUE: Did dismiss Alert with button index... %d", buttonIndex);
}


@end
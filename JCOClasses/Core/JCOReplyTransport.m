//
//  Created by nick on 28/04/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JCOTransport.h"
#import "JCOReplyTransport.h"
#import "JCO.h"

@implementation JCOReplyTransport

- (void)sendReply:(JCOIssue *)originalIssue
        description:(NSString *)description
        screenshot:(UIImage *)screenshot
        voiceData:(NSData *)voiceData
        payload:(NSDictionary *)payloadData
        fields:(NSDictionary *)customFields {

    NSLog(@"Sending reply... %@, %@ %@, %@", originalIssue.key, description, payloadData, customFields);

// issue creation url is:
// curl -u admin:admin -F media=@image.png "http://localhost:2990/jira/rest/reallife/1.0/jirarl/upload?location=blah&pid=10000&issuetype=1&summary=testing123&reporter=admin"

    NSString *path = [NSString stringWithFormat:@"rest/jconnect/latest/issue/%@", originalIssue.key];
    NSURL *url = [NSURL URLWithString:path relativeToURL:[JCO instance].url];

    ASIFormDataRequest *upRequest = [ASIFormDataRequest requestWithURL:url];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self populateCommonFields:description screenshot:screenshot voiceData:voiceData payloadData:payloadData customFields:customFields url:url upRequest:upRequest params:params];
    
    [upRequest setDelegate:self];
    [upRequest setShouldAttemptPersistentConnection:NO];
    [upRequest setTimeOutSeconds:15];
    [upRequest startAsynchronous];

    // TODO: consider doing this only if request is succesful. Else, remove last comment on FAIL?
    JCOComment * comment = [[JCOComment alloc] initWithAuthor:@"Author" systemUser:YES body:description date:[NSDate date]];
    [originalIssue.comments addObject:comment];
    [comment release];
}

#pragma mark UIAlertViewDelelgate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"REPLY: Did dismiss Alert with button index... %d, %@", buttonIndex, self.delegate);
    // dismis modal dialog. refresh table data.

}


@end
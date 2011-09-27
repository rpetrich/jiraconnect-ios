//
//  Created by niick on 27/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JMCCreateIssueDelegate.h"
#import "JMCIssueStore.h"
#import "JMC.h"

@implementation JMCCreateIssueDelegate

- (void)transportWillSend:(NSString *)issueJSON requestId:(NSString *)requestId issueKey:(NSString *)issueKey
{
    // issueJSON is {"appName":"Angry Nerds","type":"improvement","description":"Looking better...","systemName":"iPhone OS","appVersion":"1.1.3","summary":"Looking better...","systemVersion":"4.3.2","model":"iPhone Simulator","devName":"iPhone Simulator","udid":"667F57ED-92BB-5F36-889B-FA1CF175361D","appId":"com.atlassian.jiraconnect.Angry-Nerds","uuid":"D7A18E9C-C1EE-4747-95DB-41BDC56AB58E"}
    // response needs to be an Issue.json... so we can insert one here.
    JMCIssue *issue = [JMCIssue issueWith:issueJSON requestId:requestId];
    issue.hasUpdates = NO;
    issue.dateCreated = [NSDate date];
    issue.dateUpdated = [NSDate date];
    issue.uuid = requestId;
    issue.sent = NO;

    [[JMCIssueStore instance] insertIssue:issue]; // newly created issues have no comments

    // anounce that an issue was added, so the JMCIssuesView can redraw, say
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kJMCNewIssueCreated object:nil]];

}

- (void)transportDidFinish:(NSString *)response requestId:(NSString*)requestId
{
    // response is JSON like so:
    // {"key":"NERDS-49","status":"Open","title":"Gimme feedback","description":"Gimme feedback","dateUpdated":1317106927991,"hasUpdates":false,"dateCreated":1317106927991,"comments":[]}
    JMCIssue *issue = [JMCIssue issueWith:response requestId:requestId];
    // this update will ensure the issuekey gets updated in the database
    [[JMCIssueStore instance] updateIssueByUUID:issue];
    // mark the issue has sent.
    [[JMCIssueStore instance] markIssueAsSent:requestId];
}

- (void)transportDidFinishWithError:(NSError *)error requestId:(NSString*)requestId
{
    // this will be resent next time the queue is flushed
}

@end
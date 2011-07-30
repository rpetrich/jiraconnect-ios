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
#import "JMCMacros.h"
#import "JMCCrashSender.h"
#import "CrashReporter.h"
#import "JMC.h"
#import "JMCCrashTransport.h"
#import "JMCTransport.h"
#import "JMCIssueStore.h"
#import "JSON.h"

#define kJiraConnectAutoSubmitCrashes @"JiraConnectAutoSubmitCras"

@implementation JMCCrashSender

JMCCrashTransport *_transport;

- (id)init {
    self = [super init];
    if (self) {
        _transport = [[JMCCrashTransport alloc] init];
        _transport.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [_transport release];
    [super dealloc];
}


-(void)promptThenMaybeSendCrashReports {

    if (![[CrashReporter sharedCrashReporter] hasPendingCrashReport]) {
        return;
    }

    if (![[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticallySendCrashReports]) {
        NSString* description = JCOLocalizedString(@"CrashDataFoundDescription",
        @"Description explaining that crash data has been found and ask the user if the data might be uplaoded to the developers server");


        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:JCOLocalizedString(@"CrashDataFoundTitle", @"Title showing in the alert box when crash report data has been found")
                                                            message:[NSString stringWithFormat:description, [[JMC instance] getProject]]
                                                                    delegate:self
                                                  cancelButtonTitle:JCOLocalizedString(@"No", @"No")
                                                  otherButtonTitles:JCOLocalizedString(@"Yes", @"Yes"), JCOLocalizedString(@"Always", @"Always"), nil];
        [alertView show];
        [alertView release];
    } else {
      [self sendCrashReports];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [[CrashReporter sharedCrashReporter] cleanCrashReports];
            break;
        case 1:
            [self sendCrashReports];
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutomaticallySendCrashReports];
            [self sendCrashReports];
            break;
    }
}


-(void) sendCrashReports {

    if ([CrashReporter sharedCrashReporter] == nil) {
        return;
    }

	NSArray* reports = [[CrashReporter sharedCrashReporter] crashReports];
    
	for (NSString* report in reports) {
        u_int toIndex = [report length] > 500 ? 500 : [report length];
        [_transport send:@"Crash report"
             description:[[report substringToIndex:toIndex] stringByAppendingString:@"...\n(truncated)"]
             crashReport:report];
    }

}

- (void) transportDidFinish:(NSString *)response {
    [[CrashReporter sharedCrashReporter] cleanCrashReports];
    
    // response needs to be an Issue.json... so we can insert one here.
    NSDictionary *responseDict = [response JSONValue];
    JMCIssue *issue = [[JMCIssue alloc] initWithDictionary:responseDict];
    [[JMCIssueStore instance] insertOrUpdateIssue:issue]; // newly created issues have no comments
    // anounce that an issue was added, so the JCOIssuesView can redraw
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kJCONewIssueCreated object:nil]];
    [issue release];
}


@end

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
#import "JCOMacros.h"
#import "JCOCrashSender.h"
#import "CrashReporter.h"
#import "JCO.h"
#import "JCOCrashTransport.h"
#import "JCOTransport.h"

#define kJiraConnectAutoSubmitCrashes @"JiraConnectAutoSubmitCras"

@implementation JCOCrashSender

JCOCrashTransport *_transport;

- (id)init {
    self = [super init];
    if (self) {
        _transport = [[JCOCrashTransport alloc] init];
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
                                                            message:[NSString stringWithFormat:description, [[JCO instance] getProject]]
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

- (void)transportDidFinish {
    [[CrashReporter sharedCrashReporter] cleanCrashReports];
}


@end

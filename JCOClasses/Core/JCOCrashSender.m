//
//  JCOCrashSender.m
//  JiraConnect
//
//  Created by Nick Pellow on 5/11/10.
//

#import "JCOCrashSender.h"
#import "CrashReporter.h"
#import "JCO.h"
#import "JCOCrashTransport.h"

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


-(void)sendCrashReportsAfterAsking {

    if (![[CrashReporter sharedCrashReporter] hasPendingCrashReport]) {
        return;
    }

    if (![[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticallySendCrashReports]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CrashDataFoundTitle", @"Title showing in the alert box when crash report data has been found")
                                                            message:NSLocalizedString(@"CrashDataFoundDescription", @"Description explaining that crash data has been found and ask the user if the data might be uplaoded to the developers server")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"No", @"")
                                                  otherButtonTitles:NSLocalizedString(@"Yes", @""), NSLocalizedString(@"Always", @""), nil];
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

	NSArray* reports = [[CrashReporter sharedCrashReporter] crashReports];

	for (NSString* report in reports) {
        u_int toIndex = [report length] > 1000 ? 1000 : [report length];
        [_transport send:@"Crash report"
             description:[[report substringToIndex:toIndex] stringByAppendingString:@"...(truncated)"]
             crashReport:report];
    }

}

- (void)transportDidFinish {
    [[CrashReporter sharedCrashReporter] cleanCrashReports];
}


@end

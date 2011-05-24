//
//  JCOCrashSender.h
//  JiraConnect
//
//  Created by Nick Pellow on 5/11/10.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JCOTransport.h"

// flags if the crashreporter should automatically send crashes without asking the user again
#define kAutomaticallySendCrashReports @"AutomaticallySendCrashReports"

@interface JCOCrashSender : NSObject <JCOTransportDelegate, UIAlertViewDelegate> {

}

-(void) promptThenMaybeSendCrashReports;
-(void) sendCrashReports;

@end

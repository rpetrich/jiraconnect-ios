//
//  JCOCrashSender.h
//  JiraConnect
//
//  Created by Nick Pellow on 5/11/10.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#define kAutomaticallySendCrashReports @"AutomaticallySendCrashReports"		// flags if the crashreporter should automatically send crashes without asking the user again

@protocol JCOTransportDelegate;


@interface JCOCrashSender : NSObject <JCOTransportDelegate, UIAlertViewDelegate> {

}

-(void) sendCrashReportsAfterAsking;
-(void) sendCrashReports;

@end

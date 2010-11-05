//
//  JCOCrashSender.h
//  JiraConnect
//
//  Created by Nick Pellow on 5/11/10.
//  Copyright 2010 Atlassian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@interface JCOCrashSender : NSObject {

}

-(void) sendCrashReports;

@end

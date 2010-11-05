//
//  JCOCrashSender.m
//  JiraConnect
//
//  Created by Nick Pellow on 5/11/10.
//  Copyright 2010 Atlassian. All rights reserved.
//

#import "JCOCrashSender.h"
#import "CrashReporter.h"
#import "JCO.h"
#import "JSON.h"

@implementation JCOCrashSender

BOOL _sending = NO;

-(void) sendCrashReports {
	NSLog(@"Sending crash reports...");
	NSLog(@"PENDING CRASH REPORTS? %d", [[[CrashReporter sharedCrashReportSender] crashReports] count]);
	
	if (![[CrashReporter sharedCrashReportSender] hasPendingCrashReport]) {
		return;
	}
	_sending = YES;
	NSArray* reports = [[CrashReporter sharedCrashReportSender] crashReports]; 
	
	NSURL* url = [NSURL URLWithString:@"rest/jconnect/latest/crash" relativeToURL:[JCO instance].url];
	
	ASIFormDataRequest* upRequest = [ASIFormDataRequest requestWithURL:url];
	for (NSMutableDictionary* report in reports) {

		[report addEntriesFromDictionary:[[JCO instance] getMetaData]];
		NSData* jsonData = [[report JSONRepresentation]	dataUsingEncoding:NSUTF8StringEncoding];
		[upRequest setData:jsonData withFileName:@"crash.json" andContentType:@"application/json" forKey:@"issue"];	
	}
	upRequest.delegate = self;
	upRequest.timeOutSeconds = 3;
	[upRequest startAsynchronous];	
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
	_sending = NO;
	[[CrashReporter sharedCrashReportSender] cleanCrashReports];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	// TODO: possibly purge here too?
	_sending = NO;
	NSLog(@"Uploading crash reports failed. ");
}	

@end

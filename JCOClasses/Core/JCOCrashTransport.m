//
//  Created by nick on 13/05/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JCOTransport.h"
#import "JCOCrashTransport.h"
#import "JCO.h"

@implementation JCOCrashTransport

- (void)send:(NSString *)subject description:(NSString *)description crashReport:(NSString *)crashReport {

    NSString *path = [@"rest/jconnect/latest/issue/" stringByAppendingString:[[JCO instance] getProjectName]];
    NSURL *url = [NSURL URLWithString:path relativeToURL:[JCO instance].url];
    NSLog(@"Sending crash report to... %@", url);
    ASIFormDataRequest *upRequest = [ASIFormDataRequest requestWithURL:url];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:subject forKey:@"summary"];
    [params setObject:@"Crash" forKey:@"type"]; // this is used, if there is an issueType in JIRA named 'Crash'.
    [self populateCommonFields:description screenshot:nil voiceData:nil payloadData:nil customFields:nil upRequest:upRequest params:params];
    NSData *crashData = [crashReport dataUsingEncoding:NSUTF8StringEncoding];
    [upRequest setData:crashData withFileName:@"crash.txt" andContentType:@"text/plain" forKey:@"crash"];
    [upRequest setDelegate:self];
    [upRequest setShouldAttemptPersistentConnection:NO];
    [upRequest setTimeOutSeconds:15];
    [upRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"Headers: %@	", [request responseHeaders]);

    NSLog(@"Got issue key: %@", [request responseString]);
    if (request.responseStatusCode < 300) {

        NSString *msg = [NSString stringWithFormat:@"Your feedback has been received. Thank you, for the common good."];
        NSLog(@"requestSuccess: %@", msg);

        // alert the delegate!
        // TODO: also alert on FAIL..., non 200 etc
        [self.delegate transportDidFinish];

    } else {
        NSString *msg = [NSString stringWithFormat:@"There was an error submitting your feedback. Please try again soon."];
        NSLog(@"requestFail: %d, %@", request.responseStatusCode, msg);
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSString *msg = [NSString stringWithFormat:@"\n %@.\n Please try again later.", [error localizedDescription]];
    NSLog(@"CRASH requestFailed: %@. URL: %@, response code: %d", msg, [request url], [request responseStatusCode]);
}


@end
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
    [self populateCommonFields:description images:nil voiceData:nil payloadData:nil customFields:nil upRequest:upRequest params:params];
    NSData *crashData = [crashReport dataUsingEncoding:NSUTF8StringEncoding];
    [upRequest setData:crashData withFileName:@"crash.txt" andContentType:@"text/plain" forKey:@"crash"];
    [upRequest setDelegate:self];
    [upRequest setShouldAttemptPersistentConnection:NO];
    [upRequest setTimeOutSeconds:15];
    [upRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if (request.responseStatusCode < 300) {
        [self.delegate transportDidFinish];
    } else {
        [self requestFailed:request];
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if ([self.delegate respondsToSelector:@selector(transportDidFinishWithError:)]) {
        [self.delegate transportDidFinishWithError:error];
    }
    NSString *msg = [NSString stringWithFormat:@"\n %@.\n Please try again later.", [error localizedDescription]];
    NSLog(@"CRASH requestFailed: %@. URL: %@, response code: %d", msg, [request url], [request responseStatusCode]);
}


@end
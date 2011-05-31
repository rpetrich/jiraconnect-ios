
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "JCOPing.h"
#import "JCO.h"
#import "JCOIssueStore.h"
#import "ASIDownloadCache.h"


@implementation JCOPing

- (void)start {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPingDelayed) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)sendPingDelayed {
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendPing) userInfo:nil repeats:NO];
}

- (void)sendPing {

    NSString *project = [[JCO instance] getProject];
    NSString *uuid = [[JCO instance] getUUID];
    NSNumber* lastPingTime = [[NSUserDefaults standardUserDefaults] objectForKey:kJCOLastSuccessfulPingTime];
    lastPingTime = lastPingTime ? lastPingTime : [NSNumber numberWithInt:0];
    NSString *resourceUrl = [NSString stringWithFormat:kJCOTransportNotificationsPath, project, uuid, lastPingTime];

    NSURL *url = [NSURL URLWithString:resourceUrl relativeToURL:self.baseUrl];
    NSLog(@"Retrieving notifications via: %@", [url absoluteURL]);

    // send ping
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url usingCache:[ASIDownloadCache sharedCache]];
    request.secondsToCache = 60 * 24 * 7; // cache for a week?
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];

    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {

    NSString *responseString = [request responseString];
//    NSLog(@"[[request responseHeaders] allKeys] = %@", [[request responseHeaders] allKeys]);
//    NSLog(@"[[request responseHeaders] allValues] = %@", [[request responseHeaders] allValues]);
//
//    if (request.responseStatusCode == 304) {
//        NSLog(@"NOT MODIFIED responseString = %@", responseString);
//
//        NSString *sinceMillisString = [request.responseHeaders valueForKey:@"Jconnect-Sincemillis"];
//        double millis = [sinceMillisString doubleValue];
//        NSNumber * sinceMillis = [NSNumber numberWithDouble:millis];
//        [[NSUserDefaults standardUserDefaults] setObject:sinceMillis forKey:kJCOLastSuccessfulPingTime];
//        NSLog(@"304 not_modified. Time JIRA last saw this user: %@", [NSDate dateWithTimeIntervalSince1970:millis/1000]);
//        return;
//    }

    if ([responseString isEqualToString:@"null"] || [responseString isEqualToString:@""]) {
        NSLog(@"Invalid, empty response from JIRA: %@", responseString);
        return;
    }

    if (request.responseStatusCode < 300)
    {
        NSDictionary *data = [responseString JSONValue];
        [[JCOIssueStore instance] updateWithData:data];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJCOReceivedCommentsNotification object:self]; // TODO use a constant for this.
        // update the timestamp since we last requested comments.
        // sinceMillis is the server's time
        NSNumber *sinceMillis = [data valueForKey:@"sinceMillis"];
        [[NSUserDefaults standardUserDefaults] setObject:sinceMillis forKey:kJCOLastSuccessfulPingTime];
        NSLog(@"Time JIRA last saw this user: %@", [NSDate dateWithTimeIntervalSince1970:[sinceMillis doubleValue]/1000]);
    }
    else
    {
        NSLog(@"Error request comments and issues: %@", responseString);
    }
}

@synthesize baseUrl = _baseUrl;

- (void)dealloc {
    self.baseUrl = nil;
    [super dealloc];
}


@end

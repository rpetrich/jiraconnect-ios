/**
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
*/


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

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:project forKey:@"project"];
    [params setObject:uuid forKey:@"uuid"];
    [params setValue:[lastPingTime stringValue] forKey:@"sinceMillis"];
    NSString * queryString = [JCOTransport encodeParameters:params];
    NSString *resourceUrl = [NSString stringWithFormat:kJCOTransportNotificationsPath, queryString];

    NSURL *url = [NSURL URLWithString:resourceUrl relativeToURL:self.baseUrl];
    NSLog(@"Retrieving notifications via: %@", [url absoluteURL]);

    // send ping
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url usingCache:[ASIDownloadCache sharedCache]];
    [request setTimeOutSeconds:60];

//    request.secondsToCache = 60 * 24 * 7; // cache for a week?
//    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];

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

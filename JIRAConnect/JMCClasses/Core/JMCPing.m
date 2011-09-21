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

#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "JMCPing.h"
#import "JMC.h"
#import "JMCIssueStore.h"
#import "ASIDownloadCache.h"


@implementation JMCPing

- (void)start {
    // delay a little, then ping to make notificaiton not so jarring
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(sendPing) userInfo:nil repeats:NO];
}

- (void)sendPing {

    NSString *project = [[JMC instance] getProject];
    NSString *uuid = [[JMC instance] getUUID];
    NSNumber* lastPingTime = [[NSUserDefaults standardUserDefaults] objectForKey:kJMCLastSuccessfulPingTime];
    lastPingTime = lastPingTime ? lastPingTime : [NSNumber numberWithInt:0];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:project forKey:@"project"];
    [params setObject:uuid forKey:@"uuid"];
    NSString* key = [[JMC instance] getApiKey];
    [params setObject:key forKey:@"apikey"];
    [params setValue:[lastPingTime stringValue] forKey:@"sinceMillis"];
    NSString * queryString = [JMCTransport encodeParameters:params];
    NSString *resourceUrl = [NSString stringWithFormat:kJMCTransportNotificationsPath, [[JMC instance] getAPIVersion], queryString];

    NSURL *url = [NSURL URLWithString:resourceUrl relativeToURL:self.baseUrl];
    NSLog(@"Retrieving notifications via: %@", [url absoluteURL]);

    // send ping
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url usingCache:[ASIDownloadCache sharedCache]];
    [request setTimeOutSeconds:60];

    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {

    NSString *responseString = [request responseString];
    if ([responseString isEqualToString:@"null"] || [responseString isEqualToString:@""])
    {
        NSLog(@"Invalid, empty response from JIRA: %@", responseString);
        return;
    }

    if (request.responseStatusCode < 300)
    {
        NSDictionary *data = [responseString JSONValue];

        [[JMCIssueStore instance] updateWithData:data];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMCReceivedCommentsNotification object:self];
        // update the timestamp since we last requested comments.
        // sinceMillis is the server's time
        NSNumber *sinceMillis = [data valueForKey:@"sinceMillis"];
        [[NSUserDefaults standardUserDefaults] setObject:sinceMillis forKey:kJMCLastSuccessfulPingTime];
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

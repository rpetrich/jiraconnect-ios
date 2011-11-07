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

#import "JMCPing.h"
#import "JMC.h"
#import "JMCIssueStore.h"
#import "JMCTransport.h"

@implementation JMCPing

- (void)start {

    if ([JMCIssueStore instance].count > 0) {
    // delay a little, then ping to make notificaiton not so jarring
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(sendPing) userInfo:nil repeats:NO];
    }
}

- (void)sendPing {
    
    if ([JMC instance].url == nil) 
    {
        JMCDLog(@"JMC instance url not yet set. No ping this time.");
        return;
    }
    
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

    NSURL *url = [NSURL URLWithString:resourceUrl relativeToURL:[JMC instance].url];
    JMCDLog(@"Retrieving notifications via: %@", [url absoluteURL]);

    // send ping
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 60;
    
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

- (void)didReceiveComments:(NSDictionary *)comments {
    [[JMCIssueStore instance] updateWithData:comments];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMCReceivedCommentsNotification object:self];
    
    // update the timestamp since we last requested comments.
    // sinceMillis is the server's time
    NSNumber *sinceMillis = [comments valueForKey:@"sinceMillis"];
    [[NSUserDefaults standardUserDefaults] setObject:sinceMillis forKey:kJMCLastSuccessfulPingTime];
    JMCDLog(@"Time JIRA last saw this user: %@", [NSDate dateWithTimeIntervalSince1970:[sinceMillis doubleValue]/1000]);
}

- (void)flushQueue {
    [[JMC instance] flushRequestQueue];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response {
    statusCode = [(NSHTTPURLResponse *)response statusCode];
    
    [responseData release];
    responseData = [[NSMutableData alloc] init];
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    NSString *responseString = [[[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding: NSUTF8StringEncoding] autorelease];
    
    if ([responseString isEqualToString:@"null"] || [responseString isEqualToString:@""])
    {
        JMCALog(@"Invalid, empty response from JIRA: %@", responseString);
        return;
    }
    
    if (statusCode < 300)
    {
        NSDictionary *data = [JMCTransport parseJSONString:responseString];
        [self performSelectorOnMainThread:@selector(didReceiveComments:) withObject:data waitUntilDone:YES];
    }
    else
    {
        JMCALog(@"Error request comments and issues: %@", responseString);
    }
    // Flush the request Queue on App launch and once the JIRA Ping has returned and potentially rebuilt the database
    JMCDLog(@"Flushing the request queue");
    [self performSelectorOnMainThread:@selector(flushQueue) withObject:nil waitUntilDone:YES];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    NSString *responseString = [[[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding: NSUTF8StringEncoding] autorelease];
    JMCDLog(@"Ping request failed: '%@'", responseString);
}

@synthesize baseUrl = _baseUrl;

- (void)dealloc {
    self.baseUrl = nil;
    [super dealloc];
}


@end

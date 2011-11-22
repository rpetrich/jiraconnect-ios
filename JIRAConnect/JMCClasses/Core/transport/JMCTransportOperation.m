#import "JMCTransportOperation.h"
#import "JMCMacros.h"
#import "JMCRequestQueue.h"
#import "JMCTransport.h"

@interface JMCTransportOperation ()

- (void)cancelItem;
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error;

@end

@implementation JMCTransportOperation

@synthesize delegate;
@synthesize request;

#pragma mark - Init / Dealloc Methods

+ (JMCTransportOperation *)operationWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    JMCTransportOperation *operation = [[[JMCTransportOperation alloc] init] autorelease];
    operation.request = request;
    operation.delegate = delegate;
    return operation;
}

- (void)dealloc {
    delegate = nil;
    
    [super dealloc];
}

#pragma mark - NSOperation Methods

- (void)cancel {
    if (requestThread != nil) {
        [self performSelector:@selector(cancelOnRequestThread) onThread:requestThread withObject:nil waitUntilDone:YES];
    }
}

- (void)start {
    if (![self isCancelled]) {    
        [self willChangeValueForKey:@"isExecuting"];
        looping = YES;
        executing = YES;
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [NSThread detachNewThreadSelector:@selector(connect) toTarget:self withObject:nil];    
        [self didChangeValueForKey:@"isExecuting"];
    }
    else {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self cancelItem];
        [self didChangeValueForKey:@"isFinished"];
    };
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing; 
}

- (BOOL)isFinished {
    return finished;
}

#pragma mark - Private Helper Methods

- (void)cancelItem {
    NSString *requestId = [request valueForHTTPHeaderField:kJMCHeaderNameRequestId];
    [[JMCRequestQueue sharedInstance] updateItem:requestId sentStatus:JMCSentStatusRetry bumpNumAttemptsBy:1];
}

- (void)cancelOnRequestThread {
    looping = NO;
    [connection cancel];
    [self cancelItem];
}

- (void)connect {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // Synchronize the cleanup call on the main thread in case
        // the task actually finishes at around the same time.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (backgroundTask != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
                [self cancel];
            }
        });
    }];
#endif
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    requestThread = [NSThread currentThread];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection != nil) {
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (looping);
    }    
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];    
    finished = YES;
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];  
    
    requestThread = nil;
    [connection release], connection = nil;
    [pool drain];
    
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    dispatch_async(dispatch_get_main_queue(), ^{
        if (backgroundTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
            backgroundTask = UIBackgroundTaskInvalid;
        }
    });
#endif
}

#pragma mark - NSURLConnection Delegate Methods

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
    NSString *requestId = [request valueForHTTPHeaderField:kJMCHeaderNameRequestId];
    NSString *responseString = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding: NSUTF8StringEncoding];    
    if (statusCode < 300) {
        // alert the delegate!
        [self.delegate transportDidFinish:responseString requestId:requestId];
        
        // remove the request item from the queue
        JMCRequestQueue *queue = [JMCRequestQueue sharedInstance];
        [queue deleteItem:requestId];
        JMCDLog(@"%@ Request succeeded & queued item is deleted. %@ ",self, requestId);
    } else {

        JMCDLog(@"%@ Request FAILED & queued item is not deleted. %@ %@",self, requestId, responseString);
        [self connection:connection didFailWithError:nil];
    }
    [responseString release];
    looping = NO;
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    NSString *requestId = [request valueForHTTPHeaderField:kJMCHeaderNameRequestId];
    
    // TODO: time-out items in the request queue after N Attempts ?
    [[JMCRequestQueue sharedInstance] updateItem:requestId sentStatus:JMCSentStatusRetry bumpNumAttemptsBy:1];
    
    if ([self.delegate respondsToSelector:@selector(transportDidFinishWithError:statusCode:requestId:)]) {
        [self.delegate transportDidFinishWithError:error statusCode:statusCode requestId:requestId];
    }
    
#ifdef DEBUG
    NSString *msg = @"";
    if ([error localizedDescription] != nil) {
        msg = [msg stringByAppendingFormat:@"%@.\n", [error localizedDescription]];
    }
    NSString *response = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding: NSUTF8StringEncoding];
    if (response) {
        msg = [msg stringByAppendingString:response];
    }
    NSString *absoluteURL = [[request.URL absoluteURL] description];
    JMCDLog(@"Request failed: %@ URL: %@, response code: %d", msg, absoluteURL, statusCode);
    [response release];
#endif
    
    looping = NO;
}

@end

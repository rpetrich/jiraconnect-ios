#import "JMCTransportOperation.h"
#import "JMCMacros.h"
#import "JMCRequestQueue.h"
#import "JMCTransport.h"

@interface JMCTransportOperation ()

- (void)cancelItem;

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

- (void)connect {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
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
    
    [connection release], connection = nil;
    [pool drain];
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
    NSString *responseString = [[[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding: NSUTF8StringEncoding] autorelease];
    NSString *requestId = [request valueForHTTPHeaderField:kJMCHeaderNameRequestId];
    
    if (statusCode < 300) {
        // alert the delegate!
        [self.delegate transportDidFinish:responseString requestId:requestId];
        
        // remove the request item from the queue
        JMCRequestQueue *queue = [JMCRequestQueue sharedInstance];
        [queue deleteItem:requestId];
        JMCDLog(@"%@ Request succeeded & queued item is deleted. %@ ",self, requestId);
    } else {
        JMCDLog(@"%@ Request FAILED & queued item is not deleted. %@",self, requestId);
        [self connection:connection didFailWithError:nil];
    }
    
    looping = NO;
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    NSString *responseString = [[[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding: NSUTF8StringEncoding] autorelease];
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
    NSString *response = responseString;
    if (response) {
        msg = [msg stringByAppendingString:response];
    }
    
    NSString *absoluteURL = [[request.URL absoluteURL] description];
    JMCDLog(@"Request failed: %@ URL: %@, response code: %d", msg, absoluteURL, statusCode);
#endif

    looping = NO;
}

@end

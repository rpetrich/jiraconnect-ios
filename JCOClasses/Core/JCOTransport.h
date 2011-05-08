//
//  JCOTransport.h
//  JiraConnect
//
//  Created by Nick Pellow on 4/11/10.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JCOIssue.h"

@protocol JCOTransportDelegate <NSObject>

- (void)transportDidFinish;

@end


@interface JCOTransport : NSObject <UIAlertViewDelegate> {
    id <JCOTransportDelegate> _delegate;
}

@property(nonatomic, retain) id <JCOTransportDelegate> delegate;

- (void)populateCommonFields:(NSString *)description screenshot:(UIImage *)screenshot voiceData:(NSData *)voiceData payloadData:(NSDictionary *)payloadData customFields:(NSDictionary *)customFields url:(NSURL *)url upRequest:(ASIFormDataRequest *)upRequest params:(NSMutableDictionary *)params;

@end

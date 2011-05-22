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

@optional
- (void)transportDidFinishWithError:(NSError*)error;

@end


@interface JCOTransport : NSObject <UIAlertViewDelegate> {
    id <JCOTransportDelegate> _delegate;
}

@property(nonatomic, retain) id <JCOTransportDelegate> delegate;

- (void)populateCommonFields:(NSString *)description images:(NSArray *)attachments payloadData:(NSDictionary *)payloadData customFields:(NSDictionary *)customFields upRequest:(ASIFormDataRequest *)upRequest params:(NSMutableDictionary *)params;

- (void)requestFailed:(ASIHTTPRequest *)request;


@end

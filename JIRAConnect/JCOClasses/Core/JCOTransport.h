
#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JCOIssue.h"

#define kJCOTransportCreateIssuePath   @"rest/jconnect/latest/issue/create?%@"
#define kJCOTransportCreateCommentPath @"rest/jconnect/latest/issue/comment/%@"
#define kJCOTransportNotificationsPath @"rest/jconnect/latest/issue/updates?%@"

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

+ (NSMutableString *)encodeParameters:(NSDictionary *)parameters;


@end

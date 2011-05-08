//
//  Created by nick on 28/04/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>

@class JCOTransport;
@class JCOIssue;


@interface JCOReplyTransport : JCOTransport {

}
- (void)sendReply:(JCOIssue *)originalIssue description:(NSString *)description screenshot:(UIImage *)screenshot voiceData:(NSData *)voiceData payload:(NSDictionary *)payloadData fields:(NSDictionary *)customFields;

@end
//
//  Created by nick on 28/04/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>
#import "JCOTransport.h"

@interface JCOIssueTransport : JCOTransport {

    @private
    ASIFormDataRequest *createIssueRequest;
}

- (void)send:(NSString *)subject description:(NSString *)description images:(NSArray *)images payload:(NSDictionary *)payloadData fields:(NSDictionary *)customFields;

/**
 * Cancel the request.
 */
-(void) cancel;


@end
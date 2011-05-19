//
//  Created by nick on 28/04/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>
#import "JCOTransport.h"

@interface JCOIssueTransport : JCOTransport {

}

- (void)send:(NSString *)subject description:(NSString *)description images:(NSArray *)images voiceData:(NSData *)voiceData payload:(NSDictionary *)payloadData fields:(NSDictionary *)customFields;

@end
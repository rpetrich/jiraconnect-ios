//
//  Created by nick on 13/05/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>

@class JCOTransport;


@interface JCOCrashTransport : JCOTransport {
    

}

- (void)send:(NSString *)subject description:(NSString *)description crashReport:(NSString*)crashReport;

@end
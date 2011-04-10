//
//  JCPing.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 23/09/10.
//

#import <Foundation/Foundation.h>

@interface JCPing : NSObject {

    NSURL *_baseUrl;
}
@property (retain, nonatomic) NSURL * baseUrl;

- (void) start;
- (void) sendPing;

@end

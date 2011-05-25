
#import <Foundation/Foundation.h>

@interface JCOPing : NSObject {

    NSURL *_baseUrl;
}
@property (retain, nonatomic) NSURL * baseUrl;

- (void) start;
- (void) sendPing;

@end

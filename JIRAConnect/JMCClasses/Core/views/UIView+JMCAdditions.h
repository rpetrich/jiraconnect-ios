
#import <Foundation/Foundation.h>


extern NSUInteger const UIViewAutoresizingFlexibleBottomRight;


@interface UIView(JMCConvenienceAdditions)

- (CGFloat)jmc_left;
- (void)setJmc_left:(CGFloat)x;

- (CGFloat)jmc_top;
- (void)setJmc_top:(CGFloat)y;

- (CGFloat)jmc_right;
- (void)setJmc_right:(CGFloat)right;

- (CGFloat)jmc_bottom;
- (void)setJmc_bottom:(CGFloat)bottom;

- (CGFloat)jmc_width;
- (void)setJmc_width:(CGFloat)width;

- (CGFloat)jmc_height;
- (void)setJmc_height:(CGFloat)height;

- (CGSize)jmc_size;
- (void)setJmc_size:(CGSize)size;

- (void)jmc_removeAllSubviews;

@end

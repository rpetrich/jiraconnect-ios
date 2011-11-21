
#import "UIView+JMCAdditions.h"


NSUInteger const UIViewAutoresizingFlexibleBottomRight = (UIViewAutoresizingFlexibleWidth |
                                                          UIViewAutoresizingFlexibleRightMargin |
                                                          UIViewAutoresizingFlexibleHeight |
                                                          UIViewAutoresizingFlexibleBottomMargin);


@implementation UIView(JMCConvenienceAdditions)


- (CGFloat)jmc_left {
  return self.frame.origin.x;
}


- (void)setJmc_left:(CGFloat)x {
  CGRect frame = self.frame;
  frame.origin.x = x;
  self.frame = frame;
}


- (CGFloat)jmc_top {
  return self.frame.origin.y;
}


- (void)setJmc_top:(CGFloat)y {
  CGRect frame = self.frame;
  frame.origin.y = y;
  self.frame = frame;
}


- (CGFloat)jmc_right {
  return self.frame.origin.x + self.frame.size.width;
}


- (void)setJmc_right:(CGFloat)right {
  CGRect frame = self.frame;
  frame.origin.x = right - frame.size.width;
  self.frame = frame;
}


- (CGFloat)jmc_bottom {
  return self.frame.origin.y + self.frame.size.height;
}


- (void)setJmc_bottom:(CGFloat)bottom {
  CGRect frame = self.frame;
  frame.origin.y = bottom - frame.size.height;
  self.frame = frame;
}


- (CGFloat)jmc_width {
  return self.frame.size.width;
}


- (void)setJmc_width:(CGFloat)width {
  CGRect frame = self.frame;
  frame.size.width = width;
  self.frame = frame;
}


- (CGFloat)jmc_height {
  return self.frame.size.height;
}


- (void)setJmc_height:(CGFloat)height {
  CGRect frame = self.frame;
  frame.size.height = height;
  self.frame = frame;
}


- (CGSize)jmc_size {
  return self.frame.size;
}


- (void)setJmc_size:(CGSize)size {
  CGRect frame = self.frame;
  frame.size = size;
  self.frame = frame;
}


- (void)jmc_removeAllSubviews {
  while (self.subviews.count) {
    UIView* child = self.subviews.lastObject;
    [child removeFromSuperview];
  }
}


@end

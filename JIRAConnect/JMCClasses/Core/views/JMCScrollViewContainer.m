#import "JMCScrollViewContainer.h"

@implementation JMCScrollViewContainer

@synthesize scrollView;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView *child = [super hitTest:point withEvent:event];
  
  if ((child == self) && (self.scrollView.alpha == 1.0)) {
    return self.scrollView;
  } 
	
  return child;
}

- (void)dealloc {
  self.scrollView = nil;
  [super dealloc];
}

@end

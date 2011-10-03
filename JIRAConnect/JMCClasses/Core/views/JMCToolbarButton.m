#import "JMCToolbarButton.h"

@implementation JMCToolbarButton

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    int errorMargin = 10;
    CGRect largerFrame = CGRectMake(0 - errorMargin, 0 - errorMargin,
                                   self.frame.size.width + errorMargin, self.frame.size.height + errorMargin);
    return (CGRectContainsPoint(largerFrame, point) == 1) ? self : nil;
}

@end


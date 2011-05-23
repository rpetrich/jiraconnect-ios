
#import "JCOSketchScrollView.h"

@implementation JCOSketchScrollView

@synthesize scrollOn;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void) setScrollEnabled:(BOOL)enabled
{
	[super setScrollEnabled:enabled];
	self.scrollOn = enabled;
	[UIView beginAnimations:@"alpha" context:nil];
	[UIView setAnimationDuration:0.50];
		for (UIView* subView in self.subviews)
		{
			subView.alpha = enabled ? 0.50: 1.0;
		}
	[UIView commitAnimations];
	
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
	//TODO: enable auto-zoom when two touches are detected.
	// need to store previous touch and measure distance, since touches only ever has a single UITouch instance.
	return [super touchesShouldBegin:touches withEvent:event inContentView:view] ;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
	return [super touchesShouldCancelInContentView:view];
}

- (void)dealloc {
    [super dealloc];
}

@end

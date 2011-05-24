//
//  Created by nick on 24/05/11.
//
//  To change this template use File | Settings | File Templates.
//


#import "JCOSketchContainerView.h"
#import "JCOSketchView.h"


@implementation JCOSketchContainerView
UITouch *_touch;

@synthesize sketchView = _sketchView, sketch = _sketch;

- (void)retainTouchFrom:(NSSet *)touches
{
    if (_touch == nil)
    {
        _touch = [[touches anyObject] retain];
    }
}

- (void)enableScrolling:(BOOL)enabled
{
    UIView *view = self.superview;
    
    if ([view respondsToSelector:@selector(setScrollEnabled:)]) {
        [(UIScrollView *)view setScrollEnabled:enabled];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.multipleTouchEnabled = YES;

    [self retainTouchFrom:touches];

    CGPoint point = [_touch locationInView:self];
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1)
    {
        [self enableScrolling:NO];

        //TODO: probably don't want to add a new line if there are more than 1 touch.
        [self.sketch startLineAt:point];
        return;
    }

    if (touch.tapCount == 2)
    {
        [self enableScrolling:YES];
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self retainTouchFrom:touches];

    CGPoint point = [_touch locationInView:self];
    [self.sketch addPoint:point];
    [self.sketchView setNeedsDisplay];
    [self setNeedsDisplay];

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_touch release];
    _touch = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_touch release];
    _touch = nil;
}

- (void)dealloc
{
    self.sketch, self.sketchView = nil;
    [super dealloc];
}

@end
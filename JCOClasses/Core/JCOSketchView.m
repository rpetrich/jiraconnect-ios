#import "JCOSketchView.h"

@implementation JCOSketchView

@synthesize sketch = _sketch, image = _image;

UITouch *_touch;
int windowSize = 3;
int nextIndex = 0;

- (void)retainTouchFrom:(NSSet *)touches
{
    if (_touch == nil)
    {
        _touch = [[touches anyObject] retain];
    }
}

- (UITouch *)getOtherTouch:(NSSet *)touches
{
    // used to check if it was a second touch or not.

    for (UITouch *touch in touches)
    {
        if (touch != _touch)
        {
            return touch;
        }
    }
    return nil;
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
    nextIndex = 0;
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
    [self setNeedsDisplay];
    [self.superview setNeedsDisplay];

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

- (void)drawRect:(CGRect)rect
{
// draw the image
    [super drawRect:rect];

    [self.image drawInRect:rect];
    // Grab the drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextBeginPath(context);
    SketchRenderer *renderer = [[SketchRenderer alloc] initWithContext:context];
    [self.sketch visitPoints:renderer];
    [[UIColor colorWithRed:255/250 green:34.0/255.0 blue:27.0/255.0 alpha:0.8] setStroke];
    CGContextSetLineWidth(context, 2.0f);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
    [renderer release];
}

- (void)dealloc
{
    self.sketch = nil;
    [super dealloc];
}

@end

@implementation SketchRenderer

@synthesize context;

- (id)initWithContext:(CGContextRef)ctx
{
    self.context = ctx;
    return self;
}

- (void)visitLineAt:(CGPoint)point
{

    CGContextMoveToPoint(self.context, point.x, point.y);

}

- (void)visitPoint:(CGPoint)point
{
    CGContextAddLineToPoint(self.context, point.x, point.y);
}

- (void)dealloc
{
    [super dealloc];
}
@end


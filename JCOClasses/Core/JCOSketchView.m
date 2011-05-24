#import "JCOSketchView.h"

@implementation JCOSketchView

@synthesize sketch = _sketch;

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Grab the drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextBeginPath(context);
    SketchRenderer *renderer = [[SketchRenderer alloc] initWithContext:context];
    [self.sketch visitPoints:renderer];
    [[UIColor colorWithRed:255/250 green:34.0/255.0 blue:27.0/255.0 alpha:0.5] setStroke];
    CGContextSetLineWidth(context, 10.0f);
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


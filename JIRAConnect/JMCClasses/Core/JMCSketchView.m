/**
   Copyright 2011 Atlassian Software

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
**/
#import "JMCSketchView.h"

@implementation JMCSketchView

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
    [[UIColor colorWithRed:255/250 green:34.0/255.0 blue:27.0/255.0 alpha:0.8] setStroke];
    CGContextSetLineWidth(context, 2.0f);
    CGContextSetLineCap(context, kCGLineCapRound);
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


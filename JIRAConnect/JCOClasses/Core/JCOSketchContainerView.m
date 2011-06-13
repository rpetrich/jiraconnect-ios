/**
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
*/


#import "JCOSketchContainerView.h"

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
        //TODO: probably don't want to add a new line if there is more than 1 touch. This is currently handled in the Sketch.visitPoints
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
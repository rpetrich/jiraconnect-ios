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

#import "JMCSketch.h"

#define kAnimationKey @"transitionViewAnimation"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation JMCSketch

@synthesize lines, undoHistory, undoto;

- (id)init 
{
	if (self = [super init]) 
	{
		self.lines = [NSMutableArray arrayWithCapacity:1];
		self.undoHistory = [NSMutableArray arrayWithCapacity:1];
		self.undoto = 0;
	}
	return self;
}

- (id) initWithJson:(NSDictionary *)dictionary
{
	self = [self init];
	NSArray *lineArray = [dictionary objectForKey:@"lines"];
	NSString *colorRGB = [dictionary objectForKey:@"color"]; // format: rrggbb in HEX
	
	if (colorRGB)
	{
		NSScanner *theScanner = [NSScanner scannerWithString:colorRGB];
		uint colorVal;
		[theScanner scanHexInt:&colorVal];
	}

	// Scan for "x,y" - need to ignore the comma,
	NSCharacterSet *commaSet = [NSCharacterSet characterSetWithCharactersInString:@","];
	
	for (NSArray *line in lineArray) 
	{
		JMCLine * lineVal = [[JMCLine alloc]init];
		for (NSString *pointPair in line)
		{
			NSScanner *theScanner = [NSScanner scannerWithString:pointPair];
			[theScanner setCharactersToBeSkipped:commaSet];
			NSInteger x, y;
			[theScanner scanInteger:&x];
			[theScanner scanInteger:&y];
			CGPoint point = CGPointMake(x, y);
			[lineVal addPoint:point];
		}
		[lines addObject:lineVal];
		[lineVal release];
	}
	return self;
}

- (void) startLineAt:(CGPoint)point
{
	JMCLine * line = [[JMCLine alloc]init];
	[lines addObject:line];
	[line release];
	[self addPoint:point];
}

- (void) addPoint:(CGPoint)point
{
	JMCLine *currentLine = [lines lastObject];
	[currentLine addPoint:point];
}

- (void)visitPoints:(id <PointVisitor>)visitor
{
    for (JMCLine *line in self.lines)
    {
        [line.color setStroke];
        NSMutableArray *points = line.points;
        NSValue *firstValue = [points objectAtIndex:0];
        CGPoint firstPoint = [firstValue CGPointValue];
        [visitor visitLineAt:firstPoint];

        if ([points count] > 1) // don't draw single points.
        {

            for (NSValue *val in points)
            {
                CGPoint point = [val CGPointValue];
                [visitor visitPoint:point];
            }
        }

    }
}


// removes just the lines and the undoHistory.
-(void) clear 
{
	[lines removeAllObjects];
	[undoHistory removeAllObjects];
}

- (void) undo {
	JMCLine *lastLine = [lines lastObject];
	if (!lastLine) return;
	// check undoto
	if ((NSUInteger)undoto >= [lines count]) return;
	
	[undoHistory addObject:lastLine];
	[lines removeLastObject];

}

- (void) redo {
	if (![undoHistory lastObject]) return;
	[lines addObject:[undoHistory lastObject]];
	[undoHistory removeLastObject];
}

- (void) dealloc
{
	[lines release];
	[undoHistory release];
	[super dealloc];
}

@end


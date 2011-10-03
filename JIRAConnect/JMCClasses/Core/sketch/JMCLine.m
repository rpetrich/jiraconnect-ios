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
#import "JMCLine.h"

@implementation JMCLine

@synthesize points, color, curve;

- (id)init {
	if (self = [super init]) {
		self.points = [NSMutableArray arrayWithCapacity:5];
	}
	return self;
}

- (void) addPoint:(CGPoint)point
{
	[self.points addObject:[NSValue valueWithCGPoint:point]];
}

- (void) removeAllPoints 
{
	[self.points removeAllObjects];
}

- (id)copyWithZone:(NSZone *)zone
{
	JMCLine * clone = [[JMCLine alloc] init];
	clone.points = [[[NSMutableArray alloc] initWithArray:self.points copyItems:YES] autorelease];
	return clone;
}

- (void) dealloc
{
    self.color = nil;
    self.points = nil;
	[super dealloc];
}



@end

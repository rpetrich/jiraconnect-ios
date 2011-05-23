#import "JCOLine.h"

@implementation JCOLine

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
	JCOLine * clone = [[JCOLine alloc] init];
	clone.points = [[[NSMutableArray alloc] initWithArray:self.points copyItems:YES] autorelease];
	return clone;
}

- (void) dealloc
{
    self.color, self.points = nil;
	[super dealloc];
}



@end

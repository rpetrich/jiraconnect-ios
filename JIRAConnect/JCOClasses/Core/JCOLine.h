
#import <Foundation/Foundation.h>

@interface JCOLine : NSObject {
	NSMutableArray *points;
	UIColor *color;
  CGMutablePathRef curve;
}

@property (nonatomic, retain) NSMutableArray *points;
@property (nonatomic, retain) UIColor *color;
@property (assign) CGMutablePathRef curve;

- (void) addPoint:(CGPoint)point;
- (void) removeAllPoints;

@end

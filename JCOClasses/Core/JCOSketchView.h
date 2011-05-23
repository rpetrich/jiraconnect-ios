#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JCOSketch.h"
#import "JCOLine.h"

@interface JCOSketchView : UIView {

	JCOSketch *_sketch;
    UIImage *_image;
}

@property (nonatomic, retain) JCOSketch *sketch;
@property (nonatomic, retain) UIImage *image;

@end

@interface SketchRenderer : NSObject <PointVisitor>
{
	CGContextRef context;
}

@property (nonatomic) CGContextRef context;

- (id) initWithContext:(CGContextRef)ctx;

@end



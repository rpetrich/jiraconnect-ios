//
//  Created by nick on 24/05/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>
#import "JCOSketch.h"
#import "JCOSketchView.h"

@interface JCOSketchContainerView : UIView {

    JCOSketchView *_sketchView;
    JCOSketch* _sketch;
}

@property (retain, nonatomic) JCOSketch *sketch;
@property (retain, nonatomic) JCOSketchView *sketchView;

@end
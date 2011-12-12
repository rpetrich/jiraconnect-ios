//
//  JMCSketchViewPresenter.m
//  AngryNerds2
//
//  Created by Nicholas Pellow on 12/12/11.
//  Copyright (c) 2011 Nick Pellow. All rights reserved.
//

#import "JMCSketchViewControllerFactory.h"
#import "JMCSketchViewController.h"
#import "UIImage+JMCResize.h"

@implementation JMCSketchViewControllerFactory

+(JMCSketchViewController*) makeSketchViewControllerFor:(NSData*)imageData withId:(NSInteger)imageId
{
    JMCSketchViewController *sketchViewController = 
        [[[JMCSketchViewController alloc] initWithNibName:@"JMCSketchViewController" bundle:nil] autorelease];
    
    // get the original image, wire it up to the sketch controller
    sketchViewController.image = [[[UIImage alloc] initWithData:imageData] autorelease];
    sketchViewController.imageId = [NSNumber numberWithUnsignedInteger:imageId]; // set this image's id. just the index in the array

    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // On iPad, a cross dissolve works better in most cases
        sketchViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    else {
        // On iPhone, we use a flip horizontal flip
        sketchViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    return sketchViewController;
    
}

+(UIImage*) makeSketchThumbnailFor:(UIImage*)sketch
{
    return [sketch jmc_thumbnailImage:34 transparentBorder:0 cornerRadius:3.0 interpolationQuality:kCGInterpolationDefault];

}

@end

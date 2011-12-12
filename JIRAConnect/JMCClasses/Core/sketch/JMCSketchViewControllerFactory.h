//
//  JMCSketchViewPresenter.h
//  AngryNerds2
//
//  Created by Nicholas Pellow on 12/12/11.
//  Copyright (c) 2011 Nick Pellow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMCSketchViewController.h"

@interface JMCSketchViewControllerFactory : NSObject

+(JMCSketchViewController*) makeSketchViewControllerFor:(NSData*)imageData withId:(NSInteger)imageId;
+(UIImage*) makeSketchThumbnailFor:(UIImage*)sketch;

@end

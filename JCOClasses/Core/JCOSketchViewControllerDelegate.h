//
//  Created by nick on 24/05/11.
//
//  To change this template use File | Settings | File Templates.
//


@protocol JCOSketchViewControllerDelegate <NSObject>

- (void)sketchController:(UIViewController *)controller didFinishSketchingImage:(UIImage *)image withId:(NSNumber *)imageId;
- (void)sketchControllerDidCancel:(UIViewController *)controller;
- (void)sketchController:(UIViewController *)controller didDeleteImageWithId:(NSNumber*)imageId;

@end

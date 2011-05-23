#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import "JCOSketchView.h"
#import "JCOSketch.h"
#import "JCOSketchScrollView.h"
#import <QuartzCore/QuartzCore.h>


@protocol JCOSketchViewControllerDelegate <NSObject>

- (void)sketchController:(UIViewController *)controller didFinishSketchingImage:(UIImage *)image withId:(NSNumber *)id;
- (void)sketchControllerDidCancel:(UIViewController *)controller;
- (void)sketchController:(UIViewController *)controller didDeleteImageWithId:(NSNumber*)id;

@end


@interface JCOSketchViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UIActionSheetDelegate> {
	
	JCOSketch *_sketch;
    <JCOSketchViewControllerDelegate> _delegate;
	IBOutlet JCOSketchScrollView *_scrollView;
	IBOutlet JCOSketchView *_sketchView;
}

@property (nonatomic, retain) JCOSketch *sketch;
@property (nonatomic, retain) JCOSketchScrollView * scrollView;
@property (nonatomic, retain) JCOSketchView *sketchView;
@property (nonatomic, retain) id<JCOSketchViewControllerDelegate> delegate;

- (void) clearSketch;
- (void) setImage:(UIImage *)image;
-(UIImage*) createImageScaledBy:(float) dx;

- (IBAction) redoAction:(id)sender;
- (IBAction) undoAction:(id)sender;
- (IBAction) doneAction:(id)sender;
- (IBAction) cancelAction:(id)sender;

@end

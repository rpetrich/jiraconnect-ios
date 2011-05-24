#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import "JCOSketchView.h"
#import "JCOSketch.h"
#import "JCOSketchScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import "JCOSketchContainerView.h"
#import "JCOSketchViewControllerDelegate.h"

@interface JCOSketchViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UIActionSheetDelegate> {
	
@private

    <JCOSketchViewControllerDelegate> _delegate;
	IBOutlet JCOSketchScrollView* _scrollView;
    NSNumber* _imageId;
    UIImage * _image;
    JCOSketchContainerView* _mainView;
}

@property (nonatomic, retain) JCOSketchContainerView* mainView;
@property (nonatomic, retain) JCOSketchScrollView * scrollView;
@property (nonatomic, retain) id<JCOSketchViewControllerDelegate> delegate;
@property (nonatomic, retain) NSNumber* imageId;
@property (nonatomic, retain) UIImage* image;

-(UIImage*) createImageScaledBy:(float) dx;

- (IBAction) redoAction:(id)sender;
- (IBAction) undoAction:(id)sender;
- (IBAction) doneAction:(id)sender;
- (IBAction) deleteAction:(id)sender;



@end

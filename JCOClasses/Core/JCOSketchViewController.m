
#import "JCOSketchViewController.h"
#define kAnimationKey @"transitionViewAnimation"

@implementation JCOSketchViewController

@synthesize scrollView = _scrollView, delegate=_delegate, imageId = _imageId;
@synthesize image = _image, mainView = _mainView, toolbar=_toolbar;

- (void)viewDidLoad
{
	[super viewDidLoad];
    UIBarButtonItem* done  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
    UIBarButtonItem* undo  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoAction:)] autorelease];
    UIBarButtonItem* redo  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(redoAction:)] autorelease];
    UIBarButtonItem* trash = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction:)] autorelease];
    UIBarButtonItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    [self.toolbar setItems:[NSArray arrayWithObjects:trash, space, undo, redo, done, nil]];
    self.toolbar.barStyle = UIBarStyleBlack;

    [self.scrollView setCanCancelContentTouches:NO];
	self.scrollView.clipsToBounds = YES;	// default is NO, we want to restrict drawing within our scrollview
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
	self.scrollView.maximumZoomScale = 8.0;
	self.scrollView.minimumZoomScale = 0.5;
	self.scrollView.delaysContentTouches = YES;
    self.scrollView.scrollEnabled = YES;
    
	// make sketchView proportional to image
	double scale = 1.0;
	CGSize sketchSize = CGSizeMake((CGFloat)(scale * self.image.size.width), (CGFloat)(scale * self.image.size.height));
    JCOSketchView* sketchView = [[[JCOSketchView alloc] initWithFrame:CGRectMake(0, 0, sketchSize.width, sketchSize.height)] autorelease];
    sketchView.backgroundColor = [UIColor clearColor];

    JCOSketch* sketch = [[[JCOSketch alloc] init] autorelease];
    sketchView.sketch = sketch;

    JCOSketchContainerView* container = [[[JCOSketchContainerView alloc] initWithFrame:sketchView.frame] autorelease];
    container.sketch = sketch;
    container.sketchView = sketchView;
    self.mainView = container;
    [self.mainView addSubview:[[[UIImageView alloc] initWithImage:self.image] autorelease]];
    [self.mainView addSubview:sketchView];
    [self.scrollView addSubview:self.mainView];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self.scrollView setZoomScale:1.0 animated:NO];
	[self.scrollView setScrollEnabled:NO];
	[self.scrollView setContentOffset:CGPointMake(0, 0)];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scView
{

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scView
{

}

- (void)scrollViewDidEndZooming:(UIScrollView *)scView withView:(UIView *)view atScale:(float)scale
{

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scView
{
    // this needs to be wrapped.
	return self.mainView;
}
#pragma mark end

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.delegate, self.image, self.scrollView, self.mainView, self.imageId = nil; // properties take care of releasing
    self.toolbar = nil;
}

- (void) dealloc
{
    self.delegate, self.image, self.scrollView, self.mainView, self.imageId = nil; // properties take care of releasing
    self.toolbar = nil;
    [super dealloc];
}

- (void)redoAction:(id)sender
{
	[self.mainView.sketch redo];
	[self.mainView.sketchView setNeedsDisplay];
}

- (void)undoAction:(id)sender
{
	[self.mainView.sketch undo];
	[self.mainView.sketchView setNeedsDisplay];
}

- (IBAction)deleteAction:(id)sender
{
    [self.delegate sketchController:self didDeleteImageWithId:self.imageId];
}

- (IBAction)doneAction:(id)sender
{
    UIImage *image = [self createImageScaledBy:1];
    [self.delegate sketchController:self didFinishSketchingImage:image withId:self.imageId];
}

-(UIImage*) createImageScaledBy:(float) dx
{
	CGRect rect = self.mainView.bounds;
	UIGraphicsBeginImageContext(rect.size);
	CGContextScaleCTM(UIGraphicsGetCurrentContext(), dx, dx);
	CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1);
	CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
	[self.image drawInRect:rect];
	[self.mainView.sketchView drawRect:rect];

	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}


@end

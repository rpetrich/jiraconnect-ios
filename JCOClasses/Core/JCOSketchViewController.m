
#import "JCOSketchViewController.h"
#define kAnimationKey @"transitionViewAnimation"

@implementation JCOSketchViewController

@synthesize scrollView = _scrollView, sketchView = _sketchView, sketch = _sketch, delegate=_delegate;

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self.scrollView setCanCancelContentTouches:NO];
	self.scrollView.clipsToBounds = YES;	// default is NO, we want to restrict drawing within our scrollview
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
	self.scrollView.maximumZoomScale = 8.0;
	self.scrollView.minimumZoomScale = 0.5;
	self.scrollView.delaysContentTouches = YES;

	// make sketchView proportional to scrollView
	double scale = 2.0;
	CGSize sketchSize = CGSizeMake((CGFloat)(scale * self.scrollView.frame.size.width), (CGFloat)(scale * self.scrollView.frame.size.height));
	self.sketchView.frame = CGRectMake(0, 0, sketchSize.width, sketchSize.height);

	[self.scrollView setScrollEnabled:NO];

    self.sketch = [[JCOSketch alloc] init];
    self.sketchView.sketch = self.sketch;
	[self.view addSubview:self.sketchView];
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
	return self.sketchView;
}
#pragma mark end

- (void)clearSketch
{
    [self.sketch clear];
    self.sketch = nil;
    [self.sketchView setNeedsDisplay];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) dealloc
{
	self.delegate, self.sketch, self.scrollView, self.sketchView = nil; // properties take care of releasing
    [super dealloc];
}

- (void)setImage:(UIImage *)image
{
    self.sketchView.image = image;
}


- (void)redoAction:(id)sender
{
	[self.sketch redo];
	[self.sketchView setNeedsDisplay];
}

- (void)undoAction:(id)sender
{
	[self.sketch undo];
	[self.sketchView setNeedsDisplay];
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate sketchControllerDidCancel:self];
}

- (IBAction)doneAction:(id)sender
{
    UIImage *image = [self createImageScaledBy:1];
    [self.delegate sketchController:self didFinishSketchingImage:image withId:nil];
}

-(UIImage*) createImageScaledBy:(float) dx
{
	CGRect rect = self.sketchView.bounds;
	UIGraphicsBeginImageContext(rect.size);
	CGContextScaleCTM(UIGraphicsGetCurrentContext(), dx, dx);
	CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1);
	CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
	JCOSketchView * sqView = self.sketchView;
	[sqView.image drawInRect:rect];
	[sqView drawRect:rect];

	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}


@end

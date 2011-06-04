//
//  CRVActivityView.m
//
//
// Copyright (c) 2009 Stefan Saasen
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CRVActivityView.h"

#define CRV_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

// =====================================================================

@interface CRVSwallowTouchEventsView : UIView {
	@private
	UIView *validTouchReceiver;
}
@property(nonatomic, retain) UIView *validTouchReceiver;
@end

@implementation CRVSwallowTouchEventsView

@synthesize validTouchReceiver;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	return self;
}

-(void) dealloc {
	CRV_RELEASE_SAFELY(validTouchReceiver);
	[super dealloc];
}

@end

// =====================================================================

@interface CRVActivityView()
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) UILabel *label;
@property(nonatomic, retain) UIView *overlay;
@end


@implementation CRVActivityView

@synthesize activityIndicator, label, delegate, overlay;

/**
 * Creates a default CRVActivityView, adds it as a subview to parentView and centers it on the screen.
 *
 * The instance returned needs to be released.
 */
+ (CRVActivityView *) newDefaultViewForParentView:(UIView *) parentView {
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];	
	CGPoint center = CGPointMake(screenRect.size.width/2.0, screenRect.size.height/2.0);	
	return [CRVActivityView newDefaultViewForParentView:parentView center:center];
}

+ (CRVActivityView *) newDefaultViewForParentView:(UIView *) parentView center:(CGPoint) center {
	CGRect f = CGRectMake(100, 100, 144, 60);
	CRVActivityView *av = [[CRVActivityView alloc] initWithFrame:f];
	[av setHidden:YES];
	
	[parentView addSubview:av];
	
	[av setCenter:center];
	return av;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self setAlpha:1.0];
		
		// the view
		[self setOpaque:NO];
		[self setUserInteractionEnabled:YES];
		
		// The activity indicator
		UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		if(ai) {
			[ai setHidden:NO];
			[ai startAnimating];
			[self setActivityIndicator:ai];
			[ai release];
			[self addSubview:ai];
		}
		// The text
		UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, self.frame.size.width - 60, 30)];
		[lbl setTextColor:[UIColor whiteColor]];
		[lbl setText:@"Loading..."];
		[lbl setFont:[UIFont boldSystemFontOfSize:11.0]];
		[lbl setBackgroundColor:[UIColor clearColor]];
		[self setLabel: lbl];
		[lbl release];
		[self addSubview:lbl];
		
		// Cancel button
		UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(85, 15, self.frame.size.width - 60, 30)];
		[cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
		[cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchDown];
		
		[self addSubview:cancelButton];
		[cancelButton release];
		
		// Positioning
		CGPoint center = CGPointMake(24, frame.size.height/2.0);
		[ai setCenter:center];
		
		
		// Setup the overlay view...
		overlay = [[CRVSwallowTouchEventsView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
		[(CRVSwallowTouchEventsView*)overlay setValidTouchReceiver:self];
		overlay.alpha = 0.415;
		overlay.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];//[UIColor colorWithRed:0.200 green:0.200 blue:0.200 alpha:1.000];
		overlay.clearsContextBeforeDrawing = NO;
		overlay.clipsToBounds = NO;
		overlay.contentMode = UIViewContentModeScaleToFill;
		overlay.opaque = YES;
    }
    return self;
}

- (void) setText:(NSString *) theText {
	[[self label] setText:theText];
}

- (void)fillRoundedRect:(CGRect)rect inContext:(CGContextRef)context {
    float radius = 5.0f;
    
    CGContextBeginPath(context);
	CGContextSetGrayFillColor(context, 0.3, 0.75);
	CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);
	
    CGContextClosePath(context);
    CGContextFillPath(context);
}

- (void)drawRect:(CGRect)rect {
	// draw a box with rounded corners to fill the view -
	CGRect boxRect = self.bounds;
    CGContextRef ctxt = UIGraphicsGetCurrentContext();	
	boxRect = CGRectInset(boxRect, 1.0f, 1.0f);
    [self fillRoundedRect:boxRect inContext:ctxt];
}

- (void) cancel {
	if([delegate respondsToSelector:@selector(userDidCancelActivity)]) {
		[delegate userDidCancelActivity];
	}
	[self stopAnimating];
}

- (void) startAnimating { 
	[self setHidden:NO];
	[[self activityIndicator] setHidden:NO];
	[[self activityIndicator] startAnimating];

	// Add self
	[[self window] addSubview:self];
	[[self window] bringSubviewToFront:self];
	
	// Add overlay
	[[self window] insertSubview:overlay belowSubview: self];	
}

- (void) stopAnimating {
	[self setHidden:YES];
	[[self activityIndicator] setHidden:YES];
	[[self activityIndicator] stopAnimating];
	
	[[self overlay] removeFromSuperview];
}

- (void)dealloc {
	delegate = nil;
	CRV_RELEASE_SAFELY(label);
	CRV_RELEASE_SAFELY(activityIndicator);
	CRV_RELEASE_SAFELY(overlay);
    [super dealloc];
}


@end

/**
   Copyright 2011 Atlassian Software

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
**/

#import "JMCSketchScrollView.h"

@implementation JMCSketchScrollView

@synthesize scrollOn;

- (void) setScrollEnabled:(BOOL)enabled
{
	[super setScrollEnabled:enabled];
	self.scrollOn = enabled;
	[UIView beginAnimations:@"alpha" context:nil];
	[UIView setAnimationDuration:0.50];
		for (UIView* subView in self.subviews)
		{
			subView.alpha = enabled ? 0.50: 1.0;
		}
	[UIView commitAnimations];
	
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
	//TODO: enable auto-zoom when two touches are detected.
	// need to store previous touch and measure distance, since touches only ever has a single UITouch instance.
	return [super touchesShouldBegin:touches withEvent:event inContentView:view] ;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
	return [super touchesShouldCancelInContentView:view];
}

- (void)dealloc {
    [super dealloc];
}

@end



#import <Foundation/Foundation.h>
#import "JCOIssuesViewController.h"

@interface JCONotifier : NSObject {
	UIView* _view;
	UINavigationController* _viewController;
	UIToolbar* _toolbar;
	UILabel* _label;
	UIButton* _button;
}

- (id)initWithView:(UIView *)parentView;
- (void)displayNotifications:(id)sender;

@end

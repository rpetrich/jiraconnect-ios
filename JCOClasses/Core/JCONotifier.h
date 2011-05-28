#import <Foundation/Foundation.h>
#import "JCOIssuesViewController.h"

@interface JCONotifier : NSObject
{
    UIView *_view;
    UINavigationController *_viewController;
    JCOIssuesViewController *_issuesViewController;

}

@property(retain, nonatomic) UINavigationController *viewController;
@property(retain, nonatomic) JCOIssuesViewController *issuesViewController;
@property(retain, nonatomic) UIView *view;

- (id)initWithView:(UIView *)parentView;

- (void)displayNotifications:(id)sender;

- (void)populateIssuesViewController;

@end

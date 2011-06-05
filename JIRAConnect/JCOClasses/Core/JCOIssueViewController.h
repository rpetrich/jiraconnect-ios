

#import <UIKit/UIKit.h>
#import "JCOIssue.h"
#import "JCOTransport.h"

@protocol JCOTransportDelegate;
@class JCOViewController;

@interface JCOIssueViewController : UIViewController
        <UITableViewDelegate, UITableViewDataSource, JCOTransportDelegate> {
    IBOutlet UITableView* _tableView;
    IBOutlet UIButton* _replyButton;
    JCOIssue * _issue;
    NSArray * _comments;
@private
    JCOViewController *_feedbackController;
}

- (IBAction) didTouchReply:(UITextField*)sender;

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIButton* replyButton;
@property (nonatomic, retain) JCOIssue * issue;
@property (nonatomic, retain) NSArray * comments;
@property (nonatomic, retain) JCOViewController * feedbackController;
@end

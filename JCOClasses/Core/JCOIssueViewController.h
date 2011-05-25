

#import <UIKit/UIKit.h>
#import "JCOIssue.h"
#import "JCOTransport.h"

@protocol JCOTransportDelegate;

@interface JCOIssueViewController : UIViewController
        <UITableViewDelegate, UITableViewDataSource, JCOTransportDelegate> {
    IBOutlet UITableView* _tableView;
    IBOutlet UIButton* _replyButton;
    JCOIssue * _issue;
    NSArray * _comments;
}

- (IBAction) didTouchReply:(UITextField*)sender;

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIButton* replyButton;
@property (nonatomic, retain) JCOIssue * issue;
@property (nonatomic, retain) NSArray * comments;


@end

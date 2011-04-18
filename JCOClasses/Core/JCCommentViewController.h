//
//  JCCommentViewController.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 17/03/11.
//

#import <UIKit/UIKit.h>
#import "JCIssue.h"

@interface JCCommentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView* _tableView;
    IBOutlet UIButton*_replyButton;
    JCIssue* _issue;

}

- (IBAction) didTouchReply:(UITextField*)sender;

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIButton* replyButton;
@property (nonatomic, retain) JCIssue* issue;



@end

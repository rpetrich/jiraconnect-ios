//
//  JCCommentViewController.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 17/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCIssue.h"

@interface JCCommentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView* _tableView;
    JCIssue* _issue;
}

@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, retain) JCIssue* issue;

@end

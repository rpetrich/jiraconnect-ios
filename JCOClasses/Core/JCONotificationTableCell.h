//
//  JCONotificationTableCell.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 27/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCONotificationTableCell : UITableViewCell {

    UILabel* _dateLabel;
    UILabel* _titleLabel;
    UILabel* _detailsLabel;
    UILabel* _statusLabel;
}

@property (retain, nonatomic) IBOutlet UILabel* dateLabel;
@property (retain, nonatomic) IBOutlet UILabel* titleLabel;
@property (retain, nonatomic) IBOutlet UILabel* detailsLabel;
@property (retain, nonatomic) IBOutlet UILabel* statusLabel;



@end

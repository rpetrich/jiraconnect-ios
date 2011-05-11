//
//  JCOIssuePreviewCell.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 27/03/11.
//

#import <UIKit/UIKit.h>

@interface JCOIssuePreviewCell : UITableViewCell {

    UILabel* _dateLabel;
    UILabel* _titleLabel;
    UILabel* _detailsLabel;
    UIImageView* _statusLabel;
}

@property (retain, nonatomic) IBOutlet UILabel* dateLabel;
@property (retain, nonatomic) IBOutlet UILabel* titleLabel;
@property (retain, nonatomic) IBOutlet UILabel* detailsLabel;
@property (retain, nonatomic) IBOutlet UIImageView* statusLabel;



@end

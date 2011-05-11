//
//  JCOIssuePreviewCell.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 27/03/11.
//

#import "JCOIssuePreviewCell.h"


@implementation JCOIssuePreviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@synthesize dateLabel=_dateLabel, titleLabel=_titleLabel, detailsLabel=_detailsLabell, statusLabel=_statusLabel;

- (void)dealloc
{
    self.dateLabel, self.titleLabel, self.detailsLabel, self.statusLabel = nil;
    [super dealloc];
}

@end

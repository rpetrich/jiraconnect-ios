//
//  JCONotificationTableCell.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 27/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import "JCONotificationTableCell.h"


@implementation JCONotificationTableCell

@synthesize dateLabel=_dateLabel, titleLabel=_titleLabel, detailsLabel=_detailsLabell, statusLabel=_statusLabel;

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

- (void)dealloc
{
    _dateLabel = nil;
    _titleLabel = nil;
    _detailsLabel = nil;
    _statusLabel = nil;
    [super dealloc];
}

@end

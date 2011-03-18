//
//  JCMessageCell.m
//  JiraConnect
//
//  Created by Shihab Hamid on 18/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import "JCMessageCell.h"


@implementation JCMessageCell

@synthesize title = _title;
@synthesize body = _body;
@synthesize bgview = _bgview;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
    [super dealloc];
}

@end

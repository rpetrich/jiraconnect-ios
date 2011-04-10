//
//  JCMessageCell.m
//  JiraConnect
//
//  Created by Shihab Hamid on 18/03/11.
//

#import "JCMessageCell.h"


@implementation JCMessageCell

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

@synthesize title = _title, body = _body, bgview = _bgview;

- (void)dealloc
{
    self.title, self.body, self.bgview = nil;
    [super dealloc];
}

@end

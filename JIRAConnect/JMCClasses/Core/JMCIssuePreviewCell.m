/**
   Copyright 2011 Atlassian Software

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
**/

#import "JMCIssuePreviewCell.h"


@implementation JMCIssuePreviewCell

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

@synthesize dateLabel=_dateLabel, titleLabel=_titleLabel, detailsLabel=_detailsLabell, statusLabel=_statusLabel, sentStatusLabel=_sentStatusLabel;

- (void)dealloc
{
    self.dateLabel = nil;
    self.titleLabel = nil;
    self.detailsLabel = nil;
    self.statusLabel = nil;
    self.sentStatusLabel = nil;
    [super dealloc];
}

@end

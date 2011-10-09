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

#import <UIKit/UIKit.h>

@interface JMCIssuePreviewCell : UITableViewCell {

    UILabel* _dateLabel;
    UILabel* _titleLabel;
    UILabel* _detailsLabel;
    UIImageView* _statusLabel;
    UIImageView* _sentStatusLabel;
}

@property (retain, nonatomic) IBOutlet UILabel* dateLabel;
@property (retain, nonatomic) IBOutlet UILabel* titleLabel;
@property (retain, nonatomic) IBOutlet UILabel* detailsLabel;
@property (retain, nonatomic) IBOutlet UIImageView* statusLabel;
@property (retain, nonatomic) IBOutlet UIImageView* sentStatusLabel;



@end

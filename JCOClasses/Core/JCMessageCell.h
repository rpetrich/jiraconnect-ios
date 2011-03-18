//
//  JCMessageCell.h
//  JiraConnect
//
//  Created by Shihab Hamid on 18/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JCMessageCell : UITableViewCell {
    UILabel* _title;
    UILabel* _body;
    UIView* _bgview;
}

@property (nonatomic, retain) IBOutlet UILabel* title;
@property (nonatomic, retain) IBOutlet UILabel* body;
@property (nonatomic, retain) IBOutlet UIView* bgview;

@end

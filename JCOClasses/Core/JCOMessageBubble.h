//
//  Created by nick on 7/05/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>


@interface JCOMessageBubble : UITableViewCell {
    
    UIImageView *_bubble;
    UILabel *_label;
    UILabel *_detailLabel;
}

@property (nonatomic, retain) UIImageView *bubble;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UILabel *detailLabel;

- (id)initWithReuseIdentifier:(NSString *)cellIdentifierComment detailHeight:(float)detailHeight;

- (void)setText:(NSString *)string leftAligned:(BOOL)leftAligned withFont:(UIFont *)font;

@end
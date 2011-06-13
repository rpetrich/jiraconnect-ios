//
//  Created by nick on 7/05/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>


@interface JCOMessageBubble : UITableViewCell {
    
    @private
    UIImageView *bubble;
    UILabel *label;
    UILabel *detailLabel;
    float detailLabelHeight;
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UILabel *detailLabel;

- (id)initWithReuseIdentifier:(NSString *)cellIdentifierComment detailHeight:(float)detailHeight;

- (void)setText:(NSString *)string leftAligned:(BOOL)leftAligned withFont:(UIFont *)font;

@end
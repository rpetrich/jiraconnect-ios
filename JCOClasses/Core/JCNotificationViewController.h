//
//  JCNotificationViewController.h
//  JiraConnect
//
//  Created by Shihab Hamid on 23/09/10.
//

#import <UIKit/UIKit.h>

@interface JCNotificationViewController : UIViewController {
	UITextView* _textView;
}

- (IBAction) dismiss:(id)sender;
- (IBAction) reply:(id)sender;


@property (nonatomic, retain) IBOutlet UITextView* textView;

@end

//
//  JCNotificationViewController.h
//  JiraConnect
//
//  Created by Shihab Hamid on 23/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCNotificationViewController : UIViewController {
	UITextView* _textView;
}

- (IBAction) dismiss:(id)sender;

@property (nonatomic, retain) IBOutlet UITextView* textView;

@end

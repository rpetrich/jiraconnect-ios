//
//  JCOIssuesViewController.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 17/03/11.
//

#import <UIKit/UIKit.h>


@interface JCOIssuesViewController : UITableViewController {
    // this is always an array of size 2, each element is an array of JCIssues
    NSArray* _data;
}

@property (retain, nonatomic) NSArray* data;

@end

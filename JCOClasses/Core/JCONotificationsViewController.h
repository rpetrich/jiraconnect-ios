//
//  JCONotificationsViewController.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 17/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JCONotificationsViewController : UITableViewController {
    // this is always an array of size 2, each element is an array of JCIssues
    NSArray* _data;
    NSArray* _headers;
}

@property (retain, nonatomic) NSArray* data;
@property (retain, nonatomic) NSArray* headers;

@end

/**
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
*/



#import <UIKit/UIKit.h>
#import "JCOIssue.h"
#import "JCOTransport.h"

@protocol JCOTransportDelegate;
@class JCOViewController;

@interface JCOIssueViewController : UIViewController
        <UITableViewDelegate, UITableViewDataSource, JCOTransportDelegate> {
    IBOutlet UITableView* _tableView;
    IBOutlet UIButton* _replyButton;
    JCOIssue * _issue;
    NSArray * _comments;
@private
    JCOViewController *_feedbackController;
}

- (IBAction) didTouchReply:(UITextField*)sender;

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIButton* replyButton;
@property (nonatomic, retain) JCOIssue * issue;
@property (nonatomic, retain) NSArray * comments;
@property (nonatomic, retain) JCOViewController * feedbackController;
@end

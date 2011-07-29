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

#import "JCOIssueViewController.h"
#import "JCOMessageCell.h"
#import "../JMCViewController.h"
#import "JCOMessageBubble.h"
#import "JCOIssueStore.h"
#import "JSON.h"

static UIFont *font;
static UIFont* titleFont;

@implementation JCOIssueViewController

static float detailLabelHeight = 21.0f;

@synthesize tableView = _tableView, replyButton = _replyButton, issue = _issue;
@synthesize comments = _comments;
@synthesize feedbackController = _feedbackController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        font = [UIFont systemFontOfSize:14.0];
        titleFont = [UIFont boldSystemFontOfSize:14.0];
        self.replyButton.layer.cornerRadius = 7.0f;
    }
    return self;
}

- (void)dealloc {
    self.issue = nil;
    self.comments = nil;
    self.tableView = nil;
    self.replyButton = nil;
    self.feedbackController = nil;
    [super dealloc];
}

- (void)scrollToLastComment
{
    if ([self.comments count] > 0 && [self.tableView numberOfRowsInSection:1] > 0) {
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:[self.comments count] - 1 inSection:1];
        [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    [self scrollToLastComment];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)setUpCommentDataFor:(JCOIssue *)issue {
    // the first comment is a dummy comment obj that stores the description of the issue
    JCOComment *description = [[JCOComment alloc] initWithAuthor:@"Author"
                                                      systemUser:YES
                                                            body:self.issue.description
                                                            date:self.issue.dateCreated];
    NSMutableArray *commentData = [NSMutableArray arrayWithObject:description];
    [commentData addObjectsFromArray:issue.comments];
    self.comments = commentData;
    [description release];
}

- (void)setIssue:(JCOIssue *)issue {
    if (_issue != issue) {
        [_issue release];
        _issue = [issue retain];
        [self setUpCommentDataFor:issue];

    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil; // no headings
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 1 : [self.comments count];
}

- (CGSize)sizeForComment:(JCOComment *)comment font:(UIFont *)commentFont {
    return [comment.body sizeWithFont:commentFont constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {

        CGSize size = [self.issue.title sizeWithFont:titleFont constrainedToSize:CGSizeMake(300.0f, 18.0f) lineBreakMode:UILineBreakModeClip];
        return size.height + 20;



    } else {
        JCOComment *comment = [self.comments objectAtIndex:indexPath.row];
        CGFloat height = [self sizeForComment:comment font:font].height;
        return height + 15.0f + detailLabelHeight;
    }
}

- (UITableViewCell *)getBubbleCell:(UITableView *)tableView forMessage:(JCOComment *)comment {
    static NSString *cellIdentifierComment = @"JCOMessageCellComment";

    JCOMessageBubble *messageCell = (JCOMessageBubble *)[tableView dequeueReusableCellWithIdentifier:cellIdentifierComment];

    if (messageCell == nil) {
        messageCell = [[[JCOMessageBubble alloc] initWithReuseIdentifier:cellIdentifierComment detailHeight:detailLabelHeight] autorelease];
        messageCell.label.font = font;
    }
    [messageCell setText:comment.body leftAligned:comment.systemUser withFont:font];

    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    messageCell.detailLabel.text = [dateFormatter stringFromDate:comment.date];
    return messageCell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"JCOMessageCell";
        JCOMessageCell *issueCell = (JCOMessageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (issueCell == nil) {

            issueCell = [[[JCOMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            CGSize size = [self.issue.title sizeWithFont:titleFont constrainedToSize:CGSizeMake(280.0f, 18.0f) lineBreakMode:UILineBreakModeTailTruncation];
            issueCell.title = [[[UILabel alloc] initWithFrame:CGRectMake(20, 10, size.width, size.height)] autorelease];
            issueCell.title.font = titleFont;
            issueCell.title.textColor = [UIColor colorWithRed:17/255.0f green:76/255.0f blue:147/255.0f alpha:1.0];
            [issueCell addSubview:issueCell.title];
            issueCell.accessoryType = UITableViewCellAccessoryNone;
        }

        issueCell.title.text = self.issue.title;

        return issueCell;

    }
    else {
        JCOComment *comment = [self.comments objectAtIndex:indexPath.row];
        return [self getBubbleCell:tableView forMessage:comment];
    }
}

- (void)didTouchReply:(id)sender {

    //TODO: using a UINavigationController to get the nice navigationBar at the top of the feedback view. better way to do this?
    self.feedbackController = [[[JMCViewController alloc] initWithNibName:@"JMCViewController" bundle:nil] autorelease];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.feedbackController];
    navController.navigationBar.translucent = YES;
    navController.navigationBar.barStyle = UIBarStyleBlack;

    [self presentModalViewController:navController animated:YES];

    self.feedbackController.replyToIssue = self.issue;
    self.feedbackController.replyTransport.delegate = self;
    self.feedbackController.navigationItem.title = @"Reply";
    [navController release];
}

- (void)transportDidFinish:(NSString *)response {
    
    [self.feedbackController dismissActivity];
    // insert comment in db
    NSDictionary *commentDict = [response JSONValue];
    // lower case
    JCOComment *comment = [JCOComment newCommentFromDict:commentDict];
    [[JCOIssueStore instance] insertComment:comment forIssue:self.issue];
    [comment release];

    [self setUpCommentDataFor:self.issue];
    [self.tableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
    [self scrollToLastComment];
}

- (void)transportDidFinishWithError:(NSError *)error {
    [self.feedbackController dismissActivity];
}


@end

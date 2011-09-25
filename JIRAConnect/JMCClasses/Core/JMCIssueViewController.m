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

#import "JMCIssueViewController.h"
#import "JMCMessageCell.h"
#import "../JMCViewController.h"
#import "JMCMessageBubble.h"
#import "JMCIssueStore.h"
#import "JSON.h"

static UIFont *font;
static UIFont* titleFont;

@implementation JMCIssueViewController

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
        UIBarButtonItem *replyButton =
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                              target:self
                                                              action:@selector(didTouchReply:)];
        self.navigationItem.rightBarButtonItem = replyButton;
        [replyButton release];
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

- (void)setUpCommentDataFor:(JMCIssue *)issue {
    // the first comment is a dummy comment obj that stores the description of the issue
    JMCComment *description = [[JMCComment alloc] initWithAuthor:@"Author"
                                                      systemUser:YES
                                                            body:self.issue.description
                                                            date:self.issue.dateCreated];
    NSMutableArray *commentData = [NSMutableArray arrayWithObject:description];
    [commentData addObjectsFromArray:issue.comments];
    self.comments = commentData;
    [description release];
}

- (void)setIssue:(JMCIssue *)issue {
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

- (CGSize)sizeForComment:(JMCComment *)comment font:(UIFont *)commentFont {
    return [comment.body sizeWithFont:commentFont constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {

        CGSize size = [self.issue.title sizeWithFont:titleFont constrainedToSize:CGSizeMake(300.0f, 18.0f) lineBreakMode:UILineBreakModeClip];
        return size.height + 20;

    } else {
        JMCComment *comment = [self.comments objectAtIndex:indexPath.row];
        CGFloat height = [self sizeForComment:comment font:font].height;
        return height + 15.0f + detailLabelHeight;
    }
}

- (UITableViewCell *)getBubbleCell:(UITableView *)tableView forMessage:(JMCComment *)comment {
    static NSString *cellIdentifierComment = @"JMCMessageCellComment";

    JMCMessageBubble *messageCell = (JMCMessageBubble *)[tableView dequeueReusableCellWithIdentifier:cellIdentifierComment];
    CGSize detailSize = CGSizeMake(300.0f, detailLabelHeight); // TODO: un-hard code the width here

    if (messageCell == nil) {
        messageCell = [[[JMCMessageBubble alloc] initWithReuseIdentifier:cellIdentifierComment detailSize:detailSize] autorelease];
        messageCell.label.font = font;
    }
    CGSize frameSize = self.view.frame.size;

    [messageCell setText:comment.body leftAligned:comment.systemUser withFont:font size:frameSize];

    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    messageCell.detailLabel.text = [dateFormatter stringFromDate:comment.date];
    return messageCell;
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation) orientation {
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"JMCMessageCell";
        JMCMessageCell *issueCell = (JMCMessageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (issueCell == nil) {

            issueCell = [[[JMCMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            CGSize size = [self.issue.title sizeWithFont:titleFont constrainedToSize:CGSizeMake(280.0f, 18.0f) lineBreakMode:UILineBreakModeTailTruncation];
            issueCell.title = [[[UILabel alloc] initWithFrame:CGRectMake(20, 10, size.width, size.height)] autorelease];
            issueCell.title.font = titleFont;
            issueCell.title.textColor = [UIColor colorWithRed:17/255.0f green:76/255.0f blue:147/255.0f alpha:1.0];
            issueCell.autoresizesSubviews = YES;
            issueCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            [issueCell addSubview:issueCell.title];
            issueCell.accessoryType = UITableViewCellAccessoryNone;
        }

        issueCell.title.text = self.issue.title;

        return issueCell;

    }
    else {
        JMCComment *comment = [self.comments objectAtIndex:indexPath.row];
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
    // TODO: fix this. Should no longer need to be set each time reply is tapped
    self.feedbackController.replyTransport.delegate = self;
    self.feedbackController.navigationItem.title = @"Reply";
    [navController release];
}

- (void)transportDidFinish:(NSString *)response {
    // TODO: ensure to add the comment at least to the in-memory rep of the issue comment data.
    NSLog(@"TRANSPORT DID FINISH: response: %@", response);
    // insert comment in db
    NSDictionary *commentDict = [response JSONValue];
    // lower case
    JMCComment *comment = [JMCComment newCommentFromDict:commentDict];
    [[JMCIssueStore instance] insertComment:comment forIssue:self.issue];
    [comment release];
    
    [self setUpCommentDataFor:self.issue];
    [self.tableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
    [self scrollToLastComment];
}

- (void)transportDidFinishWithError:(NSError *)error {

}


@end

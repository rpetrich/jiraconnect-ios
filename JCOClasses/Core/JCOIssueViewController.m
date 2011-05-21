//
//  JCOIssueViewController.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 17/03/11.
//

#import "JCOIssueViewController.h"
#import "JCOMessageCell.h"
#import "JCOViewController.h"
#import "JCOMessageBubble.h"
#import "JCOReplyTransport.h"

static UIFont *font;


@implementation JCOIssueViewController

static float detailLabelHeight = 21.0f;

@synthesize tableView = _tableView, replyButton = _replyButton, issue = _issue;
@synthesize comments = _comments;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        font = [UIFont systemFontOfSize:14.0];
        self.replyButton.layer.cornerRadius = 7.0f;
    }
    return self;
}

- (void)dealloc
{
    self.tableView, self.issue, self.comments, self.replyButton = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)setUpCommentDataFor:(JCOIssue *)issue {
// the first comment will be a dummy object to store the description of the issue
    // TODO: need to get the date created from JIRA
    JCOComment *description = [[JCOComment alloc] initWithAuthor:@"Author"
                systemUser:YES body:self.issue.description date:self.issue.lastUpdated];
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


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:226.0/255.0 blue:237.0/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    if ([self.comments count] > 0) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:[self.comments count] -1 inSection:1];
        [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil; // no headings
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? 1 : [self.comments count];
}

-(CGSize)sizeForComment:(JCOComment *) comment font:(UIFont *)font {
    return [comment.body sizeWithFont:font constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *issueCell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return issueCell.frame.size.height;

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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0)
    {
        static NSString *cellIdentifier = @"JCOMessageCell";
        JCOMessageCell *issueCell = (JCOMessageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (issueCell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            issueCell = [topLevelObjects objectAtIndex:0];
            issueCell.accessoryType = UITableViewCellAccessoryNone;
        }

        NSString* issueData = [NSString stringWithFormat:@"Status: %@", self.issue.status];
        issueCell.title.text = self.issue.title;
        issueCell.body.text = issueData;

        //Calculate the expected size based on the font and linebreak mode of your label
        CGSize maximumLabelSize = CGSizeMake(296,9999);
        CGSize expectedLabelSize = [issueCell.body.text sizeWithFont:issueCell.body.font
                                          constrainedToSize:maximumLabelSize
                                              lineBreakMode:issueCell.body.lineBreakMode];

        //adjust the label to the new height.
        CGRect newFrame = issueCell.body.frame;
        newFrame.size.height = expectedLabelSize.height;
        issueCell.body.frame = newFrame;

        issueCell.frame = CGRectMake(0, 0, tableView.frame.size.width, 44 + expectedLabelSize.height);
        issueCell.bgview.frame = issueCell.bounds;
        return issueCell;

    }
    else
    {
        JCOComment *comment = [self.comments objectAtIndex:indexPath.row];
        UITableViewCell *messageCell = [self getBubbleCell:tableView forMessage:comment];
        return messageCell;
    }
}

- (void) didTouchReply:(id)sender {

    //TODO: using a UINavigationController to get the nice navigationBar at the top of the feedback view. better way to do this?
    JCOViewController* feedbackController = [[JCOViewController alloc] initWithNibName:@"JCOViewController" bundle:nil];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:feedbackController];
    navController.navigationBar.translucent = YES;

	[self presentModalViewController:navController animated:YES];

    feedbackController.replyToIssue = self.issue;
    feedbackController.replyTransport.delegate = self;
    feedbackController.subjectField.hidden = YES;
    CGRect subjFrame = feedbackController.subjectField.frame;
    CGRect descFrame = feedbackController.descriptionField.frame;
    CGRect newDescFrame = CGRectMake(subjFrame.origin.x, subjFrame.origin.y,
                                     subjFrame.size.width, subjFrame.size.height + descFrame.size.height + 10);
    feedbackController.descriptionField.frame = newDescFrame;
    feedbackController.navigationItem.title = @"Reply";

    [feedbackController release];
    [navController release];

}

- (void)transportDidFinish {
    [self setUpCommentDataFor:self.issue];
    [self.tableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
    if ([self.comments count] > 0) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:[self.comments count] -1 inSection:1];
        [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


@end

//
//  JCCommentViewController.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 17/03/11.
//

#import "JCCommentViewController.h"
#import "JCMessageCell.h"
#import "JCOViewController.h"
#import "JCOReplyTransport.h"

static UIFont *font;
static float dateLabelHeight = 22.0f;

@implementation JCCommentViewController

@synthesize tableView = _tableView, replyButton = _replyButton, issue = _issue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        font = [UIFont systemFontOfSize:14.0];
    }
    return self;
}

- (void)dealloc
{
    self.tableView, self.issue, self.replyButton = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:226.0/255.0 blue:237.0/255.0 alpha:1.0];
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
    if (section == 0)
    {
        return @"Issue Summary";
    }
    else
    {
        return @"Comments";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return [[self.issue comments] count];
    }
}

-(CGSize)sizeForComment:(JCComment *) comment font:(UIFont *)font {
    return [comment.body sizeWithFont:font constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *issueCell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return issueCell.frame.size.height;

    } else {
        JCComment *comment = [self.issue.comments objectAtIndex:indexPath.row];
        CGFloat height = [self sizeForComment:comment font:font].height;
        return height + 15.0f + dateLabelHeight; 
    }


}

- (UITableViewCell *)getBubbleCell:(UITableView *)tableView forMessage:(JCComment *)comment {
    static NSString *cellIdentifierComment = @"JCMessageCellComment";

    UITableViewCell *messageCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierComment];

    UIImageView *balloonView;
    UILabel *label;
    UILabel *dateLabel;

    if (messageCell == nil) {

        messageCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierComment] autorelease];

        messageCell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.separatorColor = [UIColor clearColor];


        balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
        balloonView.tag = 1;

        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = 2;
        label.numberOfLines = 0;
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.font = font;
        label.backgroundColor = [UIColor clearColor];

        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, dateLabelHeight)];
        dateLabel.tag = 3;
        dateLabel.numberOfLines = 1;
        dateLabel.lineBreakMode = UILineBreakModeClip;
        dateLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
        dateLabel.textColor = [UIColor darkGrayColor];
        
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textAlignment = UITextAlignmentCenter;

        UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0, 0, messageCell.frame.size.width, messageCell.frame.size.height)];
        [message addSubview:dateLabel];
        [message addSubview:balloonView];
        [message addSubview:label];

        [messageCell.contentView addSubview:message];

        [balloonView release];
        [message release];
        [dateLabel release];
        [label release];

    } else {
        balloonView = (UIImageView *)[messageCell.contentView viewWithTag:1];
        label = (UILabel *)[messageCell.contentView viewWithTag:2];
        dateLabel = (UILabel *)[messageCell.contentView viewWithTag:3];
    }

    CGSize size = [self sizeForComment:comment font:font];

    UIImage * balloon;
    float balloonY = 2.0f + dateLabelHeight;
    float labelY = 8.0f + dateLabelHeight;
    if (comment.systemUser) {

        CGRect frame = CGRectMake(320.0f - (size.width + 48.0f), balloonY, size.width + 28.0f, size.height + 12.0f);
        balloonView.frame = frame;
        balloonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        balloon = [[UIImage imageNamed:@"Balloon_1.png"] stretchableImageWithLeftCapWidth:20.0f topCapHeight:15.0f];
        label.frame = CGRectMake(frame.origin.x + 12.0f, labelY - 2.0f, size.width + 5.0f, size.height);
        
    } else {
        balloonView.frame = CGRectMake(0.0f, balloonY, size.width + 28.0f, size.height + 12.0f);
        balloonView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        balloon = [[UIImage imageNamed:@"Balloon_2.png"] stretchableImageWithLeftCapWidth:25.0f topCapHeight:15.0f];
        label.frame = CGRectMake(20.0f, labelY - 2.0f, size.width + 5, size.height);
    }

    balloonView.image = balloon;
    label.text = comment.body;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    dateLabel.text = [dateFormatter stringFromDate:comment.date];
    messageCell.backgroundColor = [UIColor clearColor];
    return messageCell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"JCMessageCell";

    if (indexPath.section == 0)
    {
        JCMessageCell *issueCell = (JCMessageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (issueCell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JCMessageCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            issueCell = [topLevelObjects objectAtIndex:0];
        }

        NSString* issueData = [NSString stringWithFormat:@"Issue: %@\nStatus: %@\nDescription: %@", self.issue.title, self.issue.status, self.issue.description];
        issueCell.title.text = self.issue.key;
        issueCell.body.text = issueData;
        issueCell.accessoryType = UITableViewCellAccessoryNone;

        //Calculate the expected size based on the font and linebreak mode of your label
        CGSize maximumLabelSize = CGSizeMake(296,9999);

        CGSize expectedLabelSize = [issueCell.body.text sizeWithFont:issueCell.body.font
                                          constrainedToSize:maximumLabelSize
                                              lineBreakMode:issueCell.body.lineBreakMode];

        //adjust the label to the new height.
        CGRect newFrame = issueCell.body.frame;
        newFrame.size.height = expectedLabelSize.height;
        issueCell.body.frame = newFrame;

        issueCell.frame = CGRectMake(0, 0, 320, 44 + expectedLabelSize.height);
        issueCell.bgview.frame = issueCell.bounds;
        return issueCell;

    }
    else
    {
        // TODO: consider a bubble chat ? http://stackoverflow.com/questions/351602/creating-a-chat-bubble-on-the-iphone-like-tweetie

        JCComment *comment = [self.issue.comments objectAtIndex:indexPath.row];
        UITableViewCell *messageCell = [self getBubbleCell:tableView forMessage:comment];
        return messageCell;
    }
}

- (void) didTouchReply:(id)sender {

    JCOViewController *feedbackController = [[JCOViewController alloc] initWithNibName:@"JCOViewController" bundle:nil];
    [self presentModalViewController:feedbackController animated:YES];
    feedbackController.replyToIssue = self.issue;
    feedbackController.replyTransport.delegate = self;
    feedbackController.subjectField.text = self.issue.title;
    feedbackController.subjectField.enabled = NO;
    feedbackController.subjectField.textColor = [UIColor grayColor];
    [feedbackController release];

}

- (void)transportDidFinish {
    [self.tableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
    // TODO: scroll to bottom? else, display comments in reverse chrono?
}


@end

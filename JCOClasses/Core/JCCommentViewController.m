//
//  JCCommentViewController.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 17/03/11.
//

#import "JCCommentViewController.h"
#import "JCMessageCell.h"
#import "JCOViewController.h"


@implementation JCCommentViewController

@synthesize tableView = _tableView, replyButton = _replyButton, issue = _issue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    // Do any additional setup after loading the view from its nib.
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"JCMessageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JCMessageCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];

    }
    
    JCMessageCell* messageCell = (JCMessageCell*) cell;
        
    if (indexPath.section == 0)
    {
        NSString* issueData = [NSString stringWithFormat:@"Issue: %@\nStatus: %@\nDescription: %@", self.issue.title, self.issue.status, self.issue.description];
        
        messageCell.title.text = self.issue.key;
        messageCell.body.text = issueData;
    }
    else
    {
        JCComment* comment = [self.issue.comments objectAtIndex:indexPath.row];
        

        messageCell.title.text = comment.author;
        messageCell.body.text = comment.body;
    }
    
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(296,9999);
    
    CGSize expectedLabelSize = [messageCell.body.text sizeWithFont:messageCell.body.font 
                                      constrainedToSize:maximumLabelSize 
                                          lineBreakMode:messageCell.body.lineBreakMode]; 
    
    //adjust the label the the new height.
    CGRect newFrame = messageCell.body.frame;
    newFrame.size.height = expectedLabelSize.height;
    messageCell.body.frame = newFrame;
    
    messageCell.frame = CGRectMake(0, 0, 320, 44 + expectedLabelSize.height);
    messageCell.bgview.frame = messageCell.bounds;
    
    return cell;
}

- (void) didTouchReply:(id)sender {

    JCOViewController * feedbackController = [[JCOViewController alloc] initWithNibName:@"JCOViewController" bundle:nil];
    feedbackController.replyToIssue = self.issue;

    [self presentModalViewController:feedbackController animated:YES];
    [feedbackController release];

    feedbackController.subjectField.text = self.issue.title;
    feedbackController.subjectField.enabled = NO;
    feedbackController.subjectField.textColor = [UIColor grayColor];

}


@end

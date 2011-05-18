//
//  JCOIssuesViewController.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 17/03/11.
//

#import "JCOIssuesViewController.h"
#import "JCOIssuePreviewCell.h"
#import "JCOIssueViewController.h"
#import "JCO.h"

static NSString *cellId = @"CommentCell";

@implementation JCOIssuesViewController

@synthesize data=_data;

NSDateFormatter *_dateFormatter;

-(id) initWithNibName:(NSString*) name bundle:(NSBundle*)bundle {
    
    id controller = [super initWithNibName:name bundle:bundle];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                           target:self 
                                                                                           action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(compose:)] autorelease];
    self.title = @"Your Feedback";
    _dateFormatter = [[[NSDateFormatter alloc] init] retain];
    [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return controller;
}

-(void) compose:(UIBarItem*)arg {
    [self presentModalViewController:[JCO instance].viewController animated:YES];
}

-(void) cancel:(UIBarItem*)arg {

    // Dismiss the entire notification view, the same way it gets displayed... TODO: is there a cleaner to do this?
    [UIView beginAnimations:@"animateView" context:nil];
	[UIView setAnimationDuration:0.4];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop)];

    CGRect frame = self.navigationController.view.frame;
	[self.navigationController.view setFrame:CGRectMake(0, 480, frame.size.width,frame.size.height)]; //notice this is ON screen!
	[UIView commitAnimations];
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    NSLog(@"View did cancel:");    
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.data objectAtIndex:section] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    JCOIssuePreviewCell * cell = (JCOIssuePreviewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == NULL) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JCOIssuePreviewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    NSArray* sectionData = [self.data objectAtIndex:indexPath.section];
    
    JCOIssue * issue = [sectionData objectAtIndex:indexPath.row];
    JCOComment * latestComment = [issue latestComment];
    cell.detailsLabel.text = latestComment != nil ? latestComment.body : issue.description ;
    cell.titleLabel.text = [issue title];
    NSDate *date = latestComment.date != nil ? latestComment.date : issue.lastUpdated;
    cell.dateLabel.text = [_dateFormatter stringFromDate:date];
    cell.statusLabel.hidden =! issue.hasUpdates;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    JCOIssueViewController *detailViewController = [[JCOIssueViewController alloc] initWithNibName: @"JCOIssueViewController" bundle:nil];
    
    NSArray* sectionData = [self.data objectAtIndex:indexPath.section];
    JCOIssue * issue = [sectionData objectAtIndex:indexPath.row];
    
    detailViewController.issue = issue;

    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];

    issue.hasUpdates = NO;  // once the user has tapped, the issue is no longer unread.
    [tableView reloadData]; // redraw the table.
    
}

- (void)dealloc
{
    self.data = nil;
    [_dateFormatter release];_dateFormatter = nil;
    [super dealloc];
}

@end

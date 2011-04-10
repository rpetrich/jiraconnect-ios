//
//  JCONotificationsViewController.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 17/03/11.
//

#import "JCONotificationsViewController.h"
#import "JCONotificationTableCell.h"
#import "JCCommentViewController.h"

static NSString *cellIdentifier = @"CommentCell";

@implementation JCONotificationsViewController

@synthesize data=_data, headers=_headers;

NSDateFormatter *_dateFormatter;

-(id) initWithNibName:(NSString*) name bundle:(NSBundle*)bundle {
    
    id controller = [super initWithNibName:name bundle:bundle];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                           target:self 
                                                                                           action:@selector(cancel:)] autorelease]; 
    self.title = @"Your Feedback";
    
    _dateFormatter = [[[NSDateFormatter alloc] init] retain];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    return controller;
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



- (void)dealloc
{
    self.data = nil;
    self.headers = nil;
    [_dateFormatter release];_dateFormatter = nil;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.headers objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    JCONotificationTableCell* cell = (JCONotificationTableCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == NULL) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JCONotificationCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    NSArray* sectionData = [self.data objectAtIndex:indexPath.section];
    
    JCIssue* issue = [sectionData objectAtIndex:indexPath.row];
    JCComment* latestComment = [issue latestComment];
    cell.detailsLabel.text = latestComment != nil ? latestComment.body : issue.description ;
    cell.titleLabel.text = [issue title];
    cell.dateLabel.text = [_dateFormatter stringFromDate: latestComment.date]; 
    cell.statusLabel.hidden = ! issue.hasUpdates;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    JCCommentViewController *detailViewController = [[JCCommentViewController alloc] initWithNibName: @"JCCommentViewController" bundle:nil];
    
    NSArray* sectionData = [self.data objectAtIndex:indexPath.section];
    JCIssue* issue = [sectionData objectAtIndex:indexPath.row];
    
    detailViewController.issue = issue;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
}

@end

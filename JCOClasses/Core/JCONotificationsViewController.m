//
//  JCONotificationsViewController.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 17/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import "JCONotificationsViewController.h"
#import "JCCommentViewController.h"
#import "ViewFactory.h"
#import "JCIssue.h"

static NSString *cellIdentifier = @"CommentCell";
float cellHeight;

@implementation JCONotificationsViewController

@synthesize data=_data;



-(id) initWithNibName:(NSString*) name bundle:(NSBundle*)bundle {
    
    id controller = [super initWithNibName:name bundle:bundle];
    UITableViewCell *cell = [[ViewFactory instance] cellOfKind:cellIdentifier forTable:self.tableView];
    cellHeight = cell.bounds.size.height;
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                           target:self 
                                                                                           action:@selector(cancel:)] autorelease]; 
    self.title = @"Your Feedback";
    
    return controller;
}

-(void) cancel:(UIBarItem*)arg {

    // Dismiss the entire notification view, the same way it gets displayed... TODO: is there a cleaner to do this?
    [UIView beginAnimations:@"animateView" context:nil];
	[UIView setAnimationDuration:0.4];
    CGRect frame = self.navigationController.view.frame;
	[self.navigationController.view setFrame:CGRectMake(0, 480, frame.size.width,frame.size.height)]; //notice this is ON screen!
	[UIView commitAnimations];
}


- (void)dealloc
{
    [_data release];_data = nil;  
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
    [_data release];
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
    return section == 0 ? @"New" : @"Existing";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell * cell = [[ViewFactory instance] cellOfKind:cellIdentifier forTable:tableView];
    NSArray* sectionData = [self.data objectAtIndex:indexPath.section];
    [self.tableView setRowHeight:100.0f];

    //NSLog(@"There are %d issues in this section", [sectionData count]);
    
    JCIssue* issue = [sectionData objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [issue key];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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

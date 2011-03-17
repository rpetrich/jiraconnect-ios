//
//  JCCommentViewController.m
//  JiraConnect
//
//  Created by Nicholas Pellow on 17/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import "JCCommentViewController.h"
#import "JCComment.h"

@implementation JCCommentViewController

@synthesize tableView = _tableView;
@synthesize issue = _issue;

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
    [_tableView release];
    [_issue release];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell2";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
        
    if (indexPath.section == 0)
    {
        NSString* issueData = [NSString stringWithFormat:@"Issue: %@\nStatus: %@\nDescription: %@", self.issue.title, self.issue.status, self.issue.description];
        
        cell.textLabel.text = issueData;
    }
    else
    {
        JCComment* comment = [self.issue.comments objectAtIndex:indexPath.row];
        
        NSString* commentData = [NSString stringWithFormat:@"Author: %@\nComment: %@", comment.author, comment.body];
        
        cell.textLabel.text = commentData;
    }
    
    return cell;
}

@end

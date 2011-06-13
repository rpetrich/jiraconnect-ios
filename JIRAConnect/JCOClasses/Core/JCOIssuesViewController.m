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
#import "JCOIssuesViewController.h"
#import "JCOIssuePreviewCell.h"
#import "JCOIssueViewController.h"
#import "JCO.h"
#import "UILabel+VerticalAlign.h"
#import "JCOMacros.h"

static NSString *cellId = @"CommentCell";

@implementation JCOIssuesViewController

@synthesize data = _data;

- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle {

    self = [super initWithNibName:name bundle:bundle];
    if (self) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                               target:self
                                                                                               action:@selector(cancel:)] autorelease];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                                target:self
                                                                                                action:@selector(compose:)] autorelease];

        self.title = JCOLocalizedString(@"Your Feedback", @"Title of list of previous messages");
        _dateFormatter = [[[NSDateFormatter alloc] init] retain];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return self;
}

- (void)compose:(UIBarItem *)arg {
    [self presentModalViewController:[JCO instance].viewController animated:YES];
}

- (void)cancel:(UIBarItem *)arg {

    [self dismissModalViewControllerAnimated:YES];

    // Dismiss the entire notification view, the same way it gets displayed... TODO: is there a cleaner to do this?
    [UIView beginAnimations:@"animateView" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop)];

    CGRect frame = self.navigationController.view.frame;
    [self.navigationController.view setFrame:CGRectMake(0, 480, frame.size.width, frame.size.height)]; //notice this is ON screen!
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.data objectAtIndex:section] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    JCOIssuePreviewCell *cell = (JCOIssuePreviewCell *) [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == NULL) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JCOIssuePreviewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    NSArray *sectionData = [self.data objectAtIndex:indexPath.section];

    JCOIssue *issue = [sectionData objectAtIndex:indexPath.row];
    JCOComment *latestComment = [issue latestComment];
    cell.detailsLabel.text = latestComment != nil ? latestComment.body : issue.description;
    [cell.detailsLabel alignTop];
    cell.titleLabel.text = [issue title];
    NSDate *date = latestComment.date != nil ? latestComment.date : issue.lastUpdated;
    cell.dateLabel.text = [_dateFormatter stringFromDate:date];
    cell.statusLabel.hidden = !issue.hasUpdates;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    JCOIssueViewController *detailViewController = [[JCOIssueViewController alloc] initWithNibName:@"JCOIssueViewController" bundle:nil];

    NSArray *sectionData = [self.data objectAtIndex:indexPath.section];
    JCOIssue *issue = [sectionData objectAtIndex:indexPath.row];

    detailViewController.issue = issue;

    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];

    issue.hasUpdates = NO;  // once the user has tapped, the issue is no longer unread.
    [tableView reloadData]; // redraw the table.

}

- (void)dealloc {
    self.data = nil;
    [_dateFormatter release];
    _dateFormatter = nil;
    [super dealloc];
}

@end

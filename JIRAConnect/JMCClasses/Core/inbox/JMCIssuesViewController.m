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
#import "JMCIssuesViewController.h"
#import "JMCIssuePreviewCell.h"
#import "JMCIssueViewController.h"
#import "JMC.h"
#import "UILabel+JMCVerticalAlign.h"
#import "JMCMacros.h"
#import "JMCRequestQueue.h"

static NSString *cellId = @"CommentCell";

@implementation JMCIssuesViewController

@synthesize issueStore = _issueStore;

- (id)initWithStyle:(UITableViewStyle)style {

    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                                target:self
                                                                                                action:@selector(compose:)] autorelease];

        self.title = JMCLocalizedString(@"Your Feedback", @"Title of list of previous messages");
        _dateFormatter = [[[NSDateFormatter alloc] init] retain];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:kJMCIssueUpdated object:nil];
    }
    return self;
}

- (void)compose:(UIBarItem *)arg
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController pushViewController:[[JMC instance] feedbackViewControllerWithMode:JMCViewControllerModeCustom] animated:YES];
    }
    else {
        [self presentModalViewController:[[JMC instance] feedbackViewControllerWithMode:JMCViewControllerModeDefault] animated:YES];
    }
}

- (void)cancel:(UIBarItem *)arg
{
    UIViewController *presentingViewController = nil;
    if ([self.navigationController respondsToSelector:@selector(presentingViewController)]) {
        presentingViewController = self.navigationController.presentingViewController;
    }
    else {
        presentingViewController = self.navigationController.parentViewController;
    }
    
    if (presentingViewController) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
        
        [UIView animateWithDuration:0.4 animations:^{
            CGRect frame = self.navigationController.view.frame;
            CGRect toFrame = CGRectMake(0, screenSize.height + statusBarFrame.size.height, frame.size.width, frame.size.height);
            [self.navigationController.view setFrame:toFrame];
            
        } completion:^(BOOL finished) {

        }];
    }

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

- (void)viewWillAppear:(BOOL)animated
{
    [[JMCRequestQueue sharedInstance] flushQueue];
    [super viewWillAppear:animated];

    // If we are not the root of the stack, we don't show the close button
    if ([self.navigationController.viewControllers count] > 1) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    else {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:JMCLocalizedString(@"Close", @"Close navigation item")
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(cancel:)] autorelease];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.issueStore count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    JMCIssuePreviewCell *cell = (JMCIssuePreviewCell *) [tableView dequeueReusableCellWithIdentifier:cellId];

    if (cell == NULL) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JMCIssuePreviewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    JMCIssue *issue = [self.issueStore newIssueAtIndex:indexPath.row];
        
    JMCComment *latestComment = [issue latestComment];
    cell.detailsLabel.text = latestComment != nil ? latestComment.body : issue.description;
    [cell.detailsLabel jmc_alignTop];
    cell.titleLabel.text = issue.summary;
    NSDate *date = latestComment.date != nil ? latestComment.date : issue.dateUpdated;
    cell.dateLabel.text = [_dateFormatter stringFromDate:date];
    cell.statusLabel.hidden = !issue.hasUpdates;
    JMCSentStatus sentStatus = [[JMCRequestQueue sharedInstance] requestStatusFor:issue.requestId];
    cell.sentStatusLabel.hidden = sentStatus != JMCSentStatusPermError; // TODO: after n-attempts are reached, set status to PermError.

    [issue release];
    return cell;
}

-(void) refreshTable {
    [self.tableView reloadData];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    JMCIssue *issue = [self.issueStore newIssueAtIndex:indexPath.row];
    JMCSentStatus sentStatus = [[JMCRequestQueue sharedInstance] requestStatusFor:issue.requestId];

    if (sentStatus != JMCSentStatusSuccess) {
        
        NSString* title = (sentStatus == JMCSentStatusPermError) ?
        JMCLocalizedString(@"JMCRequestPermErrorTitle", @"Alert title when message has not been sent to JIRA after N attempts.") :
        JMCLocalizedString(@"JMCRequestPendingTitle", @"Alert title when message not yet arrived in JIRA");
        NSString* message = (sentStatus == JMCSentStatusPermError) ?
        JMCLocalizedString(@"JMCRequestPermErrorMessage", @"Alert when create issue request not successful after N attempts."):
        JMCLocalizedString(@"JMCRequestPendingMessage", @"Alert when create issue request not yet successful");
        UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
            [alert show];
            [alert release];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; 

    } else {
    
        issue.comments = [self.issueStore loadCommentsFor:issue];
        JMCIssueViewController *detailViewController = [[JMCIssueViewController alloc] initWithNibName:@"JMCIssueViewController" bundle:nil];
        detailViewController.issue = issue;
        
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
        
        [self.issueStore markAsRead:issue];
        [tableView reloadData]; // redraw the table.
    }
    [issue release];
}
#pragma mark end

- (void)dealloc {
    self.issueStore = nil;
    [_dateFormatter release];
    _dateFormatter = nil;
    [super dealloc];
}

@end

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
#import "JMCAttachmentsViewController.h"
#import "JMCSketchViewController.h"
#import "UIImage+JMCResize.h"
#import "JMCMacros.h"
#import "JMCAttachmentItem.h"
#import "JMCSketchViewControllerFactory.h"

@interface JMCAttachmentsViewController ()

- (void)removeAttachmentAtIndex:(NSInteger)index;


@end

@implementation JMCAttachmentsViewController

@synthesize attachments = _attachments;
@synthesize delegate;

#pragma mark - UIViewController Methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.title = JMCLocalizedString(@"JMCAttachmentsTitle", @"Attachments");
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self.attachments count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *identifier = @"AttachmentCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
    }
    
    JMCAttachmentItem *attachment = [self.attachments objectAtIndex:indexPath.row];
    cell.imageView.image = attachment.thumbnail;
    if (attachment.data) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f kB", round([attachment.data length] / 1000.0 * 100) / 100];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (attachment.type) {
        case JMCAttachmentTypeRecording:
            cell.textLabel.text = JMCLocalizedString(@"JMCRecordingLabel", "Recording");
            break;
            
        case JMCAttachmentTypeImage:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.text = JMCLocalizedString(@"JMCImageLabel", "Image");
            break;
            
        case JMCAttachmentTypeCustom:
            cell.textLabel.text = JMCLocalizedString(@"JMCCustomLabel", "Custom");
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [self removeAttachmentAtIndex:indexPath.row];
}

#pragma mark - UITableViewDelegate Methods

- (UITableViewCellEditingStyle)aTableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    JMCAttachmentItem *attachment = [self.attachments objectAtIndex:indexPath.row];

    if (attachment.type == JMCAttachmentTypeImage) {
        JMCSketchViewController* controller = 
            [JMCSketchViewControllerFactory makeSketchViewControllerFor:attachment.data withId:indexPath.row];
        controller.delegate = self;
        [self presentModalViewController:controller animated:YES];
        currentAttachmentItemIndex = indexPath.row;
    }
}

#pragma mark - JMCSketchViewControllerDelegate

- (void)sketchController:(UIViewController *)controller didFinishSketchingImage:(UIImage *)image withId:(NSNumber *)imageId
{

    NSUInteger imgIndex = [imageId unsignedIntegerValue];
    JMCAttachmentItem *attachment = [self.attachments objectAtIndex:imgIndex];

    attachment.data = UIImagePNGRepresentation(image);
    attachment.thumbnail = [JMCSketchViewControllerFactory makeSketchThumbnailFor:image];   
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:currentAttachmentItemIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    if ([self.delegate respondsToSelector:@selector(attachmentsViewController:didChangeAttachment:)]) {
        [self.delegate attachmentsViewController:self didChangeAttachment:attachment];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sketchControllerDidCancel:(UIViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sketchController:(UIViewController *)controller didDeleteImageWithId:(NSNumber *)imageId
{
    [self dismissModalViewControllerAnimated:YES];
    [self removeAttachmentAtIndex:[imageId unsignedIntegerValue]];
}

#pragma mark - Helper Methods

- (void)removeAttachmentAtIndex:(NSInteger)attachmentIndex 
{
    JMCAttachmentItem *attachment = [self.attachments objectAtIndex:attachmentIndex];
    
    [self.attachments removeObjectAtIndex:attachmentIndex];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:attachmentIndex inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    
    if ([self.delegate respondsToSelector:@selector(attachmentsViewController:didDeleteAttachment:)]) {
        [self.delegate attachmentsViewController:self didDeleteAttachment:attachment];
    }
}

- (void)setAttachments:(NSMutableArray *)newAttachments  
{
    [newAttachments retain];
    [_attachments release];
    _attachments = newAttachments;
    
    [self.tableView reloadData];
}

#pragma mark - Memory Managements Methods

- (void)dealloc 
{
    self.delegate = nil;
    self.attachments = nil;
    [super dealloc];
}

@end

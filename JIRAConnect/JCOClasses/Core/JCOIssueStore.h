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

#import <Foundation/Foundation.h>
#import "JCOIssue.h"

@interface JCOIssueStore : NSObject {
    int _newIssueCount;
    int _count; // the total issue count, including new and old issues
}

@property (assign, nonatomic) int newIssueCount;
@property (assign, nonatomic) int count;

- (void) createSchema:(BOOL)dropExisting;
- (void) updateWithData:(NSDictionary*)data;
- (JCOIssue *) initIssueAtIndex:(NSUInteger)index;
- (NSArray *) loadCommentsFor:(JCOIssue*)issue;
- (void) insertOrUpdateIssue:(JCOIssue *)issue;
- (void) insertComment:(JCOComment *)comment forIssue:(JCOIssue *)issue;
- (void) markAsRead:(JCOIssue *)issue;
+ (JCOIssueStore *) instance;

@end

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
#import "JMCAttachmentItem.h"

typedef enum {
    JMCIssueTypeCrash,
    JMCIssueTypeFeedback
} JMCIssueType;

@protocol JMCCustomDataSource <NSObject>

@optional

/**
* Returns a custom attachment that will be attached to the issue.
*/
-(JMCAttachmentItem *) attachment;

/**
* A dictionary containing any specialized custom fields (keyed by custom field name) 
* to be set on any JIRAs created by JIRA Connect.
* NB: custom field names should be *all* lower case.
*/
-(NSDictionary *) customFields;

/**
* Return the name of the issue type in JIRA, for a given JMCIssueType.
* If there is an issue type of the same in the JIRA server, then it will be used
* as the issue type.
*/
-(NSString *)jiraIssueTypeNameFor:(JMCIssueType) type;

/**
* If non-nil, use this project name when creating feedback. Otherwise, the bundle name is used.
* This value can be either the JIRA Project's name, _or_ its Project Key. e.g. JRA
* NB: This is deprecated. Use a JMCOptions instead.
*/
-(NSString *)project;


@end

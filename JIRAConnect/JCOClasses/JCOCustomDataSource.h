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

typedef enum {
  JCOIssueTypeCrash,
  JCOIssueTypeFeedback
} JCOIssueType;

@protocol JCOCustomDataSource <NSObject>

@optional

/**
* Return a dictionary that will be serialized to json and attached to any feedback created by the user.
*/
-(NSDictionary *) payload;

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
-(NSString *)jiraIssueTypeNameFor:(JCOIssueType) type;

/**
* If non-nil, use this project name when creating feedback. Otherwise, the bundle name is used.
* This value can be either the JIRA Project's name, _or_ its Project Key. e.g. JRA
*/
-(NSString *)project;

/**
 * If YES the location data (lat/lng) will be sent as a part of the issue, this is NO by default.
 */
-(BOOL) locationEnabled;

/**
 * If YES users will be able to submit voice recordings with their feedback, this is YES by default.
 */
-(BOOL) voiceEnabled;

/**
 * If YES users will be able to submit screenshots/photos with their feedback, this is YES by default.
 */
-(BOOL) photosEnabled;


@end

//
//  Created by nick on 11/04/11.
//
//  To change this template use File | Settings | File Templates.
//


@protocol JCOCustomDataSource <NSObject>

@optional

/**
* Return a dictionary that will be serialized to json and attached to any feedback created by the user.
*/
-(NSDictionary *) payloadFor:(NSString *) issueTitle;

/**
* A dictionary containing any specialized custom fields (keyed by custom field name) to be set on any JIRAs created
* by JIRA Connect.
*/
-(NSDictionary *) customFieldsFor:(NSString *) issueTitle;

/**
* If non-nil, use this project name when creating feedback. Otherwise, the bundle name is used.
* This value can be either the JIRA Project's name, _or_ its Project Key. e.g. JRA
*/
-(NSString *)project;

@end
/**
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
*/

//
//  Created by nick on 11/04/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>

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
* If non-nil, use this project name when creating feedback. Otherwise, the bundle name is used.
* This value can be either the JIRA Project's name, _or_ its Project Key. e.g. JRA
*/
-(NSString *)project;

/**
 * If YES the location data (lat/lng) will be sent as a part of the issue, this is NO by default.
 */
-(BOOL) locationEnabled;

@end

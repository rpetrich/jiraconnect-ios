//
//  JCIssue.m
//  JiraConnect
//
//  Created by Shihab Hamid on 17/03/11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#import "JCIssue.h"


@implementation JCIssue

@synthesize key = _key;
@synthesize status = _status;
@synthesize title = _title;
@synthesize description = _description;
@synthesize comments = _comments;

- (void) dealloc {
	[_key release];
    [_status release];
    [_title release];
    [_description release];
    [_comments release];
	[super dealloc];
}

- (id) initWithDictionary:(NSDictionary*)map {
	if ((self = [super init])) {
		self.key = [map objectForKey:@"key"];
        self.status = [map objectForKey:@"status"];
        self.title = [map objectForKey:@"title"];
        self.description = [map objectForKey:@"description"];   
    }
    
    NSLog(@"self = %@", self);
    
	return self;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"key: %@, status %@, title: %@", self.key, self.status, self.title];
}

@end

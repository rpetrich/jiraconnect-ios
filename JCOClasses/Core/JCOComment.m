//
//  JCOComment.m
//  JiraConnect
//
//  Created by Shihab Hamid on 17/03/11.
//

#import "JCOComment.h"


@implementation JCOComment

@synthesize author = _author, systemUser = _systemUser, body = _body, date = _date;

- (void) dealloc {
    self.author, self.body, self.date = nil;
	[super dealloc];
}

- (id) initWithAuthor:(NSString*)p_author systemUser:(BOOL)p_sys body:(NSString*)p_body date:(NSDate*)p_date {
	if ((self = [super init])) {
		self.author = p_author;
        self.body = p_body;
        self.date = p_date;
        self.systemUser = p_sys;
	}
	return self;
}

@end

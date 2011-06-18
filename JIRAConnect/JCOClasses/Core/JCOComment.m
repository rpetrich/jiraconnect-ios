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

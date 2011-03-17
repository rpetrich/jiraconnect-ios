//
//  ViewFactory.m
//  squiggle
//
//  Created by Nicholas Pellow on 8/06/09.
//  Copyright 2009 Nick Pellow. All rights reserved.
//

#import "ViewFactory.h"

@implementation ViewFactory

static ViewFactory *singleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        singleton = [[ViewFactory alloc] initWithNib:@"JCCommentCell"];
    }

}
+(ViewFactory*)instance
{
	return singleton;
}


- (id) initWithNib: (NSString*)aNibName
{
    if (self == [super init]) {
        viewTemplateStore = [[NSMutableDictionary alloc] init];
        NSArray * templates = [[NSBundle mainBundle] loadNibNamed:aNibName owner:self options:nil];

        for (id template in templates) {
            if ([template isKindOfClass:[UITableViewCell class]]) {
                UITableViewCell * cellTemplate = (UITableViewCell *)template;
                NSString * key = cellTemplate.reuseIdentifier;
                if (key) {
                    [viewTemplateStore setObject:[NSKeyedArchiver
                                                  archivedDataWithRootObject:template]
                                          forKey:key];
                } else {
                    @throw [NSException exceptionWithName:@"Unknown cell"
                                                   reason:@"Cell has no reuseIdentifier"
                                                 userInfo:nil];
                }
            }
        }
    }
	
    return self;
}


- (void) dealloc
{
    [viewTemplateStore release];
    [super dealloc];
}

- (UITableViewCell*)cellOfKind: (NSString*)theCellKind forTable: (UITableView*)aTableView
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:theCellKind];
	    
    if (!cell) {
        NSData * cellData = [viewTemplateStore objectForKey:theCellKind];
        if (cellData) {
            cell = [NSKeyedUnarchiver unarchiveObjectWithData:cellData];
        } else {
            NSLog(@"Don't know nothing about cell of kind %@", theCellKind);
        }
    }
    return cell;
}

@end

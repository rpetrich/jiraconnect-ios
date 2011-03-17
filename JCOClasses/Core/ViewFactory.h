//
//  ViewFactory.h
//  squiggle
//
//  Created by Nicholas Pellow on 8/06/09.
//  Copyright 2009 Nick Pellow. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ViewFactory : NSObject {
    NSMutableDictionary * viewTemplateStore;
}

- (id) initWithNib: (NSString*)aNibName;

- (UITableViewCell*)cellOfKind: (NSString*)theCellKind forTable: (UITableView*)aTableView;

+ (ViewFactory*)instance;

@end

//
//  JCComment.h
//  JiraConnect
//
//  Created by Shihab Hamid on 17/03/11.
//

#import <Foundation/Foundation.h>


@interface JCComment : NSObject {
    NSString* _author;
    BOOL _systemUser;
    NSString* _body;
    NSDate* _date;
}

@property (nonatomic, retain) NSString* author;
@property (nonatomic, assign) BOOL systemUser;
@property (nonatomic, retain) NSString* body;
@property (nonatomic, retain) NSDate* date;


- (id) initWithAuthor:(NSString*)p_author systemUser:(BOOL)p_sys body:(NSString*)p_body date:(NSDate*)p_date;

@end

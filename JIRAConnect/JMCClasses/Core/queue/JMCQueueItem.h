//
//  Created by nick on 20/09/11.
//
//  To change this template use File | Settings | File Templates.
//


#import <Foundation/Foundation.h>


@interface JMCQueueItem : NSObject {
    NSString* _uuid; // globally unique id for this item.
    NSString* _url;
    NSDictionary* _parameters;
    NSArray* _attachments;
}

@property (retain, nonatomic) NSString* uuid;
@property (retain, nonatomic) NSString* url;
@property (retain, nonatomic) NSDictionary* parameters;
@property (retain, nonatomic) NSArray* attachments;

-(id)initWith:(NSString*)uuid url:(NSString*)url parameters:(NSDictionary*) params attachments:(NSArray*)attachments;
-(void)write;
-(void)read;

@end
//
//  Created by nick on 11/04/11.
//
//  To change this template use File | Settings | File Templates.
//


@protocol JCOPayloadDataSource<NSObject>

-(NSDictionary *) payloadFor:(NSString *) issueTitle;

@end
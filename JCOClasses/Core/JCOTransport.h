//
//  JCOTransport.h
//  JiraConnect
//
//  Created by Nick Pellow on 4/11/10.
//  Copyright 2010 Atlassian . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@protocol JCOTransportDelegate <NSObject>

-(void) transportDidFinish;

@end


@interface JCOTransport : NSObject <UIAlertViewDelegate> {
	id<JCOTransportDelegate> _delegate;
}

@property (nonatomic, retain) id<JCOTransportDelegate> delegate;

-(void) send:(NSString*)title description:(NSString*)description 
							   screenshot:(UIImage*)screenshot 
							 andVoiceData:(NSData*)voice;

@end

//
//  JCORecorder.h
//  JiraConnect
//
//  Created by Nick Pellow on 4/11/10.
//  Copyright 2010 Atlassian . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface JCORecorder : NSObject {

	AVAudioRecorder* _recorder;
}

@property (nonatomic, retain) AVAudioRecorder* recorder;

+(JCORecorder*) initialize;
-(void) start;
-(NSData*) stop;

@end

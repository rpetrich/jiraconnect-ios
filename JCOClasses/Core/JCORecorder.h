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
	float recordTime;
}

@property (nonatomic, retain) AVAudioRecorder* recorder;
@property (assign) float recordTime; // maximum voice record time in seconds


-(void) start;
-(void) stop;
-(float) currentDuration;
-(float) previousDuration;
-(NSData*) audioData;
-(void) cleanUp;

@end

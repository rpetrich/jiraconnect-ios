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
	float _lastDuration;
	NSDate* _startTime;

}

@property (nonatomic, retain) AVAudioRecorder* recorder;
@property (assign) float recordTime;
@property (assign) float lastDuration;
@property (nonatomic, retain) NSDate* startTime;


+(JCORecorder*) initialize;

-(void) start;
-(void) stop;
-(float) currentDuration;
-(NSData*) audioData;

@end

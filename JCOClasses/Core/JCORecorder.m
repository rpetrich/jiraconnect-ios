//
//  JCORecorder.m
//  JiraConnect
//
//  Created by Nick Pellow on 4/11/10.
//  Copyright 2010 Atlassian . All rights reserved.
//

#import "JCORecorder.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation JCORecorder

NSString* _recorderFilePath;

+(JCORecorder*) initialize {

	return [[JCORecorder alloc] init];
}

-(id)init {
	if (self = [super init]) {
		
		self.recordTime = 10;
		_recorderFilePath = [[NSString stringWithFormat:@"%@/jiraconnect-recording.caf", DOCUMENTS_FOLDER] retain];
		
		// delete the previous recording.
		NSFileManager *fm = [NSFileManager defaultManager];
		[fm removeItemAtPath:_recorderFilePath error:nil];
		
		AVAudioSession *audioSession = [AVAudioSession sharedInstance];
		NSError *err = nil;
		[audioSession setCategory :AVAudioSessionCategoryRecord error:&err];
		if(err){
			NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
			return nil;
		}
		[audioSession setActive:YES error:&err];
		err = nil;
		if(err){
			NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
			return nil;
		}
		
		NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
		
		[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
		[recordSetting setValue:[NSNumber numberWithFloat:22050] forKey:AVSampleRateKey]; 
		[recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
		
		[recordSetting setValue :[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
		[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
		[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
		
		
		// Create a recording file	
		NSURL *url = [NSURL fileURLWithPath:_recorderFilePath];
		err = nil;
		AVAudioRecorder* recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
		if(!recorder){
			NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
			UIAlertView *alert =
			[[UIAlertView alloc] initWithTitle: @"Warning"
									   message: [err localizedDescription]
									  delegate: nil
							 cancelButtonTitle:@"OK"
							 otherButtonTitles:nil];
			[alert show];
			[alert release];
			return nil;
		}
		
		//prepare to record
		[recorder prepareToRecord];
		recorder.meteringEnabled = YES;	
		self.recorder = recorder;
	}
	return self;
	
}

-(void) start {

	AVAudioSession* session = [AVAudioSession sharedInstance];
	BOOL audioHWAvailable =  session.inputIsAvailable;
	if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: @"Audio input hardware not available"
								  delegate: nil
						 cancelButtonTitle: @"OK"
						 otherButtonTitles: nil];
        [cantRecordAlert show];
        [cantRecordAlert release]; 
        return;
	}
	[self.recorder recordForDuration:self.recordTime];
	self.startTime = [NSDate date];
}

-(void) stop {	
	[_recorder stop];
	_lastDuration = -[_startTime timeIntervalSinceNow];
	_startTime = nil;
	NSLog(@"Saved audio data to: %@", _recorderFilePath);
}

-(float) currentDuration {
	return -[_startTime timeIntervalSinceNow];
}

-(NSData*) audioData {
	NSURL *url = [NSURL fileURLWithPath: _recorderFilePath];
	NSError *err = nil;
	NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
	if(!audioData) {
		NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
	}
	return audioData;	
}

@synthesize recorder=_recorder, lastDuration=_lastDuration, startTime=_startTime, recordTime;

- (void) dealloc {
	[super dealloc];
	[_recorder release]; _recorder = nil;
	[_recorderFilePath release]; _recorderFilePath = nil;
	[_startTime release]; _startTime = nil;
}	

@end

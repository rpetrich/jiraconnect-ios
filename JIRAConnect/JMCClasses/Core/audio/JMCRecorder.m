/**
   Copyright 2011 Atlassian Software

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
**/

#import "JMCMacros.h"
#import "JMCRecorder.h"


#define TMP_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]

@implementation JMCRecorder

NSString *_recorderFilePath;

+ (JMCRecorder *)instance {
    static JMCRecorder *singleton;
    if (singleton == nil) {
        singleton = [[[JMCRecorder alloc] init] retain];
    }
    return singleton;
}

+ (BOOL)audioRecordingIsAvailable {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    return session.inputIsAvailable;
}

- (id)init {
    if ((self = [super init])) {

        self.recordTime = 10;
        _recorderFilePath = [[NSString stringWithFormat:@"%@/jiraconnect-recording.aac", TMP_FOLDER] retain];

        // delete the previous recording.
        [self cleanUp];

        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
        if (err) {
            JMCALog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            return nil;
        }
        [audioSession setActive:YES error:&err];
        err = nil;
        if (err) {
            JMCALog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            return nil;
        }

        NSMutableDictionary *recordSetting = [[[NSMutableDictionary alloc] init] autorelease];

        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];

        // Create a recording file
        NSURL *url = [NSURL fileURLWithPath:_recorderFilePath];
        err = nil;
        AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];

        if (!recorder) {
            JMCALog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            return nil;
        }

        //prepare to record
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        self.recorder = recorder;
        [recorder release];
    }
    return self;
}

- (void)start {
    [self.recorder recordForDuration:self.recordTime];
}

- (void)stop {
    [self.recorder stop];
}

- (float)currentDuration {
    return (float) self.recorder.currentTime;
}

- (float)previousDuration {

    AVAudioPlayer *player = [[[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil] autorelease];
    player.volume = 1;
    return (float) player.duration;

}

- (NSData *)audioData {

    if ([self previousDuration] <= 0.0f) {
        return nil;
    }

    NSURL *url = [NSURL fileURLWithPath:_recorderFilePath];
    NSError *err = nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options:0 error:&err];
    if (!audioData) {
        JMCALog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    }
    return audioData;
}


// deletes any cached audio files
- (void)cleanUp {
    [[NSFileManager defaultManager] removeItemAtPath:_recorderFilePath error:nil];
}

@synthesize recorder = _recorder, recordTime = _recordTime;

- (void)dealloc {
    self.recorder = nil;
    [_recorderFilePath release];
    _recorderFilePath = nil;
    [super dealloc];
}

@end

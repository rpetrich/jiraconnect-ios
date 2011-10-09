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


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface JMCRecorder : NSObject {

    AVAudioRecorder *_recorder;
    float _recordTime;
}

@property(nonatomic, retain) AVAudioRecorder *recorder;
@property(assign) float recordTime; // maximum voice record time in seconds


+ (JMCRecorder *)instance;

+ (BOOL)audioRecordingIsAvailable;

- (void)start;

- (void)stop;

- (float)currentDuration;

- (float)previousDuration;

- (NSData *)audioData;

- (void)cleanUp;

@end

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
#import "JMCLine.h"


@protocol PointVisitor <NSObject>
@optional

- (void) visitLineAt:(CGPoint)point;
- (void) visitPoint:(CGPoint)point;

@end


@interface JMCSketch : NSObject {
	NSMutableArray* lines; 
	NSMutableArray* undoHistory;
	int undoto;
}

@property(retain, nonatomic) NSMutableArray* lines;
@property(retain, nonatomic) NSMutableArray* undoHistory;

@property int undoto;

- (id) initWithJson:(NSDictionary *)dictionary;

- (void) clear;
- (void) startLineAt:(CGPoint)point;
- (void) addPoint:(CGPoint)point;
- (void) undo;
- (void) redo;
- (void) visitPoints:(id <PointVisitor>)visitor;

@end

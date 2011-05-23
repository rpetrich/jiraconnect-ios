#import "JCOLine.h"


@protocol PointVisitor <NSObject>
@optional

- (void) visitLineAt:(CGPoint)point;
- (void) visitPoint:(CGPoint)point;

@end


@interface JCOSketch : NSObject {
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

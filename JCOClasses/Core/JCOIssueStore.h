
#import <Foundation/Foundation.h>


@interface JCOIssueStore : NSObject {
    // array of JCIssues 
    NSArray* _issues;
    int _newIssueCount;
}

@property (nonatomic, retain) NSArray* issues;
@property (assign, nonatomic) int newIssueCount;


- (void) updateWithData:(NSDictionary*)data;
+ (JCOIssueStore *) instance;

@end

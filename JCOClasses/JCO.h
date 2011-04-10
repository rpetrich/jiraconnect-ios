//
//  JCO.h
//  JiraConnect
//
//  Created by Nicholas Pellow on 21/09/10.
//

#import <Foundation/Foundation.h>
#import "JCOViewController.h"
#import "CrashReporter.h"

@interface JCO : NSObject {
	NSURL* _url;	
}

@property (nonatomic, retain) NSURL* url;

+ (JCO*) instance;

- (void) configureJiraConnect:(NSString*) withUrl;
- (JCOViewController*) viewController;
- (void) displayNotifications;
- (NSDictionary*) getMetaData;

@end

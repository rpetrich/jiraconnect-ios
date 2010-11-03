//
//  JCLocation.h
//  JiraConnect
//
//  Created by Shihab Hamid on 23/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface JCLocation : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *_locationManager;
	float _lat;
	float _lon;
}

@property (nonatomic, readonly) float lat;
@property (nonatomic, readonly) float lon;


@end

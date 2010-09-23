//
//  JCLocation.m
//  JiraConnect
//
//  Created by Shihab Hamid on 23/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JCLocation.h"

@implementation JCLocation

@synthesize lat=_lat;
@synthesize lon=_lon;

-(void) dealloc {
	[_locationManager release]; _locationManager = nil;
	[super dealloc];	
}

- (id)init {
	if (self = [super init]) {
		_lat = 0.0f;
		_lon = 0.0f;
		
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
		_locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest; // best accuracy, gogo battery drain
		[_locationManager startUpdatingLocation];
	}
	return self;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	_lat = newLocation.coordinate.latitude;
	_lon = newLocation.coordinate.longitude;
}

@end

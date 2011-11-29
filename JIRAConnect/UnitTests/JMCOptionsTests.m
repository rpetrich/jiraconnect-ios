//
//  UnitTests.m
//  UnitTests
//
//  Created by Nicholas Pellow on 3/10/11.
//  Copyright (c) 2011 Nick Pellow. All rights reserved.
//

#import "JMCOptionsTests.h"
#import "JMC.h"

@implementation JMCOptionsTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testConfigurationOptions
{
    NSDictionary* customFields = [NSDictionary dictionaryWithObject:@"value"
                                                             forKey:@"fieldname"];
    JMCOptions* options = [JMCOptions optionsWithUrl:@"https://connect.onjira.com" 
                                             projectKey:@"NERDS" 
                                              apiKey:@"SECRET-123" 
                                              photos:YES
                                               voice:YES
                                            location:YES
                                      crashReporting:YES
                                       notifications:YES
                                        customFields:customFields];

    STAssertEqualObjects(@"https://connect.onjira.com/", options.url, @"URL not set correctly");
    STAssertEqualObjects(@"NERDS", options.projectKey, @"Project Key not set correctly");
    STAssertEqualObjects(customFields, options.customFields, @"Custom Fields not set correctly");

    STAssertTrue(options.photosEnabled, @"Photos are not enabled");
    STAssertTrue(options.voiceEnabled, @"Photos are not enabled");
    STAssertTrue(options.locationEnabled, @"Photos are not enabled");
    STAssertTrue(options.crashReportingEnabled, @"Crash Reporting is not enabled");
    STAssertTrue(options.notificationsEnabled, @"Notifications are not enabled");
}

-(void) testLoadConfigFromFile
{
    JMCOptions *options2 = [JMCOptions optionsWithContentsOfFile:@"UnitTests/JMCTestConfiguration.plist"];
    STAssertNotNil(options2, @"Could not load options from file");
    STAssertEqualObjects(options2.url, @"http://connect.onjira.com/", @"URL not loaded from file");
    STAssertEqualObjects(options2.projectKey, @"NERDS", @"ProjectKey not loaded from file");
    STAssertNotNil(options2.customFields, @"Custom fields not loaded from file");

    NSDictionary *customFields = options2.customFields;
    STAssertEqualObjects([customFields objectForKey:@"customfield1"], @"value1", @"Invalid custom field 1");
    STAssertEqualObjects([customFields objectForKey:@"customfield2"], @"value2", @"Invalid custom field 2");
    STAssertFalse(options2.photosEnabled, @"Photos Enabled not set correctly");
    STAssertFalse(options2.voiceEnabled, @"Voice Enabled not set correctly");
    STAssertFalse(options2.locationEnabled, @"Location Enabled not set correctly");
}

@end

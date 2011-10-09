//
//  UnitTests.m
//  UnitTests
//
//  Created by Nicholas Pellow on 3/10/11.
//  Copyright (c) 2011 Nick Pellow. All rights reserved.
//

#import "UnitTests.h"
#import "JMC.h"

@implementation UnitTests

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
    JMCOptions* options = [JMCOptions optionsWithUrl:@"http://connect.onjira.com" 
                                             project:@"NERDS" 
                                              apiKey:@"SECRET-123" 
                                              photos:YES
                                               voice:YES
                                            location:YES
                                        customFields:customFields];

    STAssertEqualObjects(@"http://connect.onjira.com", options.url, @"URL not set correctly");
    STAssertEqualObjects(@"NERDS", options.projectKey, @"Project Key not set correctly");
    STAssertEqualObjects(customFields, options.customFields, @"Custom Fields not set correctly");

    STAssertTrue(options.photosEnabled, @"Photos are not enabled");
    STAssertTrue(options.voiceEnabled, @"Photos are not enabled");
    STAssertTrue(options.locationEnabled, @"Photos are not enabled");



}

@end

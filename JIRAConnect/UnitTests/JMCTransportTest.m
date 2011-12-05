//
//  JMCTransportTest.m
//  JIRAConnect
//
//  Created by Nicholas Pellow on 6/12/11.
//  Copyright (c) 2011 coravy. All rights reserved.
//

#import "JMCTransportTest.h"
#import "JMCTransport.h"

@implementation JMCTransportTest

// All code under test must be linked into the Unit Test bundle
- (void)testJSONParsing
{
    NSString* jsonString = @"{\"key\":\"value\"}";
    NSDictionary* dict = (NSDictionary*)[JMCTransport parseJSONString:jsonString];
    STAssertEqualObjects(@"value", [dict objectForKey:@"key"], @"JSON Serialisation error");
    NSString* resultStr = [JMCTransport buildJSONString:dict];
    STAssertEqualObjects(resultStr, jsonString, @"JSON Deserialisation error");
}


@end

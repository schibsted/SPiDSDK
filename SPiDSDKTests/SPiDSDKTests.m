//
//  SPiDSDKTests.m
//  SPiDSDKTests
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDSDKTests.h"
#import "SPiDUtils.h"

@implementation SPiDSDKTests

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

- (void)testURLEncodingShouldPercentEncode
{
    NSString *unencodedURLParameter = @"Barnes & Noble";
    NSString *encodedParameter = [SPiDUtils urlEncodeQueryParameter:unencodedURLParameter];

    XCTAssert([encodedParameter isEqualToString:@"Barnes%20%26%20Noble"]);
}

@end

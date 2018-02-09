//
//  SPiDAgreementsTests.m
//  SPiDSDK
//
//  Created by Joakim Gyllström on 2016-12-20.
//  Copyright © 2016 Mikael Lindström. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SPiDAgreements.h"

@interface SPiDAgreementsTests : XCTestCase

@end

@implementation SPiDAgreementsTests

- (void)testParseValidResponse {
    NSData *data = [@"{\"name\":\"SPP Container\",\"version\":\"0.2\",\"api\":2,\"object\":\"User\",\"type\":\"element\",\"code\":200,\"request\":{\"reset\":3600,\"limit\":360000,\"remaining\":360000},\"debug\":{\"route\":{\"name\":\"Has Access to User\",\"url\":\"/api/2/user/{id}/agreements\",\"controller\":\"Api/2/User.user_agreements\"},\"params\":{\"options\":[],\"where\":{\"id\":\"1234\"}}},\"meta\":null,\"error\":null,\"data\":{\"agreements\":{\"platform\":true,\"client\":true}}}" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    SPiDAgreements *agreements = [SPiDAgreements parseAgreementsFrom:json];
    
    XCTAssertTrue(agreements.client);
    XCTAssertTrue(agreements.platform);
}

- (void)testParseMissingClient {
    NSData *data = [@"{\"name\":\"SPP Container\",\"version\":\"0.2\",\"api\":2,\"object\":\"User\",\"type\":\"element\",\"code\":200,\"request\":{\"reset\":3600,\"limit\":360000,\"remaining\":360000},\"debug\":{\"route\":{\"name\":\"Has Access to User\",\"url\":\"/api/2/user/{id}/agreements\",\"controller\":\"Api/2/User.user_agreements\"},\"params\":{\"options\":[],\"where\":{\"id\":\"1234\"}}},\"meta\":null,\"error\":null,\"data\":{\"agreements\":{\"platform\":true}}}" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    SPiDAgreements *agreements = [SPiDAgreements parseAgreementsFrom:json];

    XCTAssertNil(agreements);
}

@end

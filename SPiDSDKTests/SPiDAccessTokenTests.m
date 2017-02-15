//
//  SPiDAccessTokenTests.m
//  SPiDSDK
//
//  Created by Joakim Gyllström on 2017-02-15.
//

#import <XCTest/XCTest.h>
#import "SPiDAccessToken.h"
#import "NSDictionary+Test.h"

@interface SPiDAccessTokenTests: XCTestCase

@end

@implementation SPiDAccessTokenTests

- (void)testValidClientToken {
    NSDictionary *dictionary = [NSDictionary sp_JSONStubWithName:@"ValidClientToken"];
    SPiDAccessToken *token = [[SPiDAccessToken alloc] initWithDictionary:dictionary];

    XCTAssertTrue([token isKindOfClass:[SPiDAccessToken class]], "Failed to parse valid client token");
    XCTAssertNil(token.userID, "User ID should be nil for client token");
}

- (void)testValidUserToken {
    NSDictionary *dictionary = [NSDictionary sp_JSONStubWithName:@"ValidUserToken"];
    SPiDAccessToken *token = [[SPiDAccessToken alloc] initWithDictionary:dictionary];

    XCTAssertTrue([token isKindOfClass:[SPiDAccessToken class]], "Failed to parse valid access token");
    XCTAssertTrue([token.userID isKindOfClass:[NSString class]], "User token should have a string user id");
}

- (void)testNullUserId {
    // A case that appeared in the api.
    // We should get a token, but user id should be nil and not NSNull
    NSMutableDictionary *dictionary = [[NSDictionary sp_JSONStubWithName:@"ValidClientToken"] mutableCopy];
    dictionary[@"user_id"] = [NSNull null];
    SPiDAccessToken *token = [[SPiDAccessToken alloc] initWithDictionary:dictionary];

    XCTAssertTrue([token isKindOfClass:[SPiDAccessToken class]], "Failed to parse valid client token");
    XCTAssertNil(token.userID, "User ID should be nil for client token");
}

- (void)testBooleanUserId {
    // As of this writing, this is the 'normal' case.
    // Just make double sure that we can handle it properly
    NSMutableDictionary *dictionary = [[NSDictionary sp_JSONStubWithName:@"ValidClientToken"] mutableCopy];
    dictionary[@"user_id"] = [NSNumber numberWithBool:NO];
    SPiDAccessToken *token = [[SPiDAccessToken alloc] initWithDictionary:dictionary];

    XCTAssertTrue([token isKindOfClass:[SPiDAccessToken class]], "Failed to parse valid client token");
    XCTAssertNil(token.userID, "User ID should be nil for client token");
}

- (void)testInvalidAccessToken {
    NSMutableDictionary *dictionary = [[NSDictionary sp_JSONStubWithName:@"ValidClientToken"] mutableCopy];
    dictionary[@"access_token"] = [NSNumber numberWithBool:NO];
    SPiDAccessToken *token = [[SPiDAccessToken alloc] initWithDictionary:dictionary];

    XCTAssertNil(token, "No access token token, should return nil");
}

- (void)testInvalidRefreshToken {
    NSMutableDictionary *dictionary = [[NSDictionary sp_JSONStubWithName:@"ValidClientToken"] mutableCopy];
    dictionary[@"refresh_token"] = [NSNumber numberWithBool:NO];
    SPiDAccessToken *token = [[SPiDAccessToken alloc] initWithDictionary:dictionary];

    XCTAssertNil(token, "No retry token, should return nil");
}

@end

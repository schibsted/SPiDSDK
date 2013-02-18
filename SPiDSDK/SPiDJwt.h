//
//  SPiDJwt
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const JSON_WEB_ALGORITHM_HS256 = @"HS256";
static NSString *const JSON_WEB_TOKEN_TYP_JWT = @"JWT";

/** Contains a JWT token */

@interface SPiDJwt : NSObject

///---------------------------------------------------------------------------------------
/// @name Properties
///---------------------------------------------------------------------------------------

// Header
//@property(strong, nonatomic) NSString *alg;
//@property(strong, nonatomic) NSString *typ;

// MUST requirements for JWT over OAuth 2.0
@property(strong, nonatomic) NSString *iss; // issuer (facebook appid)
@property(strong, nonatomic) NSString *sub; // authorization
@property(strong, nonatomic) NSString *aud; // intended url (SPiDTokenURL)
@property(strong, nonatomic) NSDate *exp;   // expiration date for the token

// SPiD Specific
@property(strong, nonatomic) NSString *tokenType;  // type of token (facebook)
@property(strong, nonatomic) NSString *tokenValue;

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------
/** Creates a JWT token from a dictionary

 @param dictionary Dictionary containing JWT parameters
 @return `SPiDJwt`
*/
+ (SPiDJwt *)jwtTokenWithDictionary:(NSDictionary *)dictionary;

/* Encodes JWT token to a string

 @return JWT encoded as a string
*/
- (NSString *)encodedJwtString;

@end
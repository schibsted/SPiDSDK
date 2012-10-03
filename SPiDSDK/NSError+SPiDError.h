//
//  NSError+SPiDError
//  SPiDSDK
//
//  Created by mikaellindstrom on 10/2/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Adds helper methods to `NSError` for more organized code. */
@interface NSError (SPiDError)

/** Creates a new `NSError` with SPiD OAuth2 domain and given dictionary.

 @param dictionary Dictionary containing error data received from SPiD
 @return Returns `NSError` with the given data.
 */

+ (NSError *)errorFromJSONData:(NSDictionary *)dictionary;

/** Creates a new `NSError` with SPiD OAuth2 domain and the given string.

 @param errorString Error received from SPiD.
 @return Returns `NSError` with the given data.
 */
+ (NSError *)oauth2ErrorWithString:(NSString *)errorString;

/** Creates a new `NSError` with SPiD OAuth2 domain and the given paramters

 @param code Error code.
 @param description Error description.
 param description Error reason.
 @return Returns `NSError` with the given data.
 */
+ (NSError *)oauth2ErrorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason;

/** Not implemented yet */
+ (NSError *)apiErrorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason;

@end

enum {
    SPiDOAuth2RedirectURIMismatchErrorCode = -1000,
    SPiDOAuth2UnauthorizedClientErrorCode = -1001,
    SPiDOAuth2AccessDeniedErrorCode = -1002,
    SPiDOAuth2InvalidRequestErrorCode = -1003,
    SPiDOAuth2UnsupportedResponseTypeErrorCode = -1004,
    SPiDOAuth2InvalidScopeErrorCode = -1005,
    SPiDOAuth2InvalidGrantErrorCode = -1006,
    SPiDOAuth2InvalidClientErrorCode = -1007,
    SPiDOAuth2InvalidClientIDErrorCode = -1008, // Replaced by "invalid_client" in draft 10 of OAuth 2.0
    SPiDOAuth2InvalidClientCredentialsErrorCode = -1009, // Replaced by "invalid_client" in draft 10 of OAuth 2.0

    SPiDOAuth2InvalidTokenErrorCode = -1010, // Protected resource errors
    SPiDOAuth2InsufficientScopeErrorCode = -1011,
    SPiDOAuth2ExpiredTokenErrorCode = -1012,

    SPiDOAuth2UnsupportedGrantTypeErrorCode = -1020, // Grant type error

    SPiDJSONParseErrorCode = -1030 // JSON Parse error

};
typedef NSUInteger SPiDErrorCode;
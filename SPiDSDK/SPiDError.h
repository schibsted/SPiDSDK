//
//  NSError+SPiDError
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Subclass of `NSError` to add support for multiple error descriptions.


 */
@interface SPiDError : NSError

/** Dictionary of error descriptions */
@property(strong, nonatomic) NSDictionary *descriptions;

/** Creates a new `SPiDError` with SPiD OAuth2 domain and given dictionary.

 @param dictionary Dictionary containing error data received from SPiD
 @return Returns `SPiDError` with the given data.
 */

+ (id)errorFromJSONData:(NSDictionary *)dictionary;

/** Creates a new `SPiDError` with SPiD OAuth2 domain and the given string.

 @param errorString Error received from SPiD.
 @return Returns `SPiDError` with the given data.
 */
+ (id)oauth2ErrorWithString:(NSString *)errorString;

/** Creates a new `SPiDError` with SPiD OAuth2 domain and the given paramters

 @param errorCode Error code.
 @param descriptions Dictionary container error descriptions.
 @param reason Error reason.
 @return Returns `SPiDError` with the given data.
 */
+ (id)oauth2ErrorWithCode:(NSInteger)errorCode reason:(NSString *)reason descriptions:(NSDictionary *)descriptions;

/** Creates a new `SPiDError` with SPiD API domain and the given paramters 

 @param errorCode Error code.
 @param descriptions Dictionary container error descriptions.
 @param reason Error reason.
 @return Returns `SPiDError` with the given data.
 */
+ (id)apiErrorWithCode:(NSInteger)errorCode reason:(NSString *)reason descriptions:(NSDictionary *)descriptions;

/**

 @param errorDomain Error domain string.
 @param error code from api or 0
 @return Returns internal SPiD code for the given error.
 */
+ (NSInteger)getSPiDOAuth2ErrorCodeFromDomain:(NSString *)errorDomain andAPIErrorCode:(NSInteger)apiError;

+ (id)errorFromNSError:(NSError *)error;


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
    SPiDOAuth2InvalidUserCredentialsErrorCode = -1030,
    SPiDOAuth2UnverifiedUserErrorCode = -1031,
    SPiDOAuth2UnknownUserErrorCode = -1032,

    SPiDInvalidEmailAddressErrorCode = -1050,
    SPiDInvalidPasswordErrorCode = -1051,

    SPiDUserAbortedLogin = -1100,
    SPiDJSONParseErrorCode = -1200, // JSON Parse error

    SPiDAPIExceptionErrorCode = -1300,
    SPiDAPIExceptionExistingUser = -1302 //User already exists
};
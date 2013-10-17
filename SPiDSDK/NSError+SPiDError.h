//
//  NSError+SPiDError.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 14/10/13.
//  Copyright (c) 2013 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>


// TODO: move to global header
// TODO: add specific userInfo keys 
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
    
    SPiDOAuth2InvalidTokenErrorCode = -1010,
    SPiDOAuth2InsufficientScopeErrorCode = -1011,
    SPiDOAuth2ExpiredTokenErrorCode = -1012,
    
    SPiDOAuth2UnsupportedGrantTypeErrorCode = -1020,
    SPiDOAuth2InvalidUserCredentialsErrorCode = -1030,
    SPiDOAuth2UnverifiedUserErrorCode = -1031,
    SPiDOAuth2UnknownUserErrorCode = -1032,
    
    SPiDInvalidEmailAddressErrorCode = -1050,
    SPiDInvalidPasswordErrorCode = -1051,
    
    SPiDUserAbortedLogin = -1100,
    SPiDJSONParseErrorCode = -1200,
    
    SPiDAPIExceptionErrorCode = -1300
    
};

@interface NSError (SPiDError)

+ (id)spidErrorFromJSONData:(NSDictionary *)dictionary;

+ (id)spidOauth2ErrorWithString:(NSString *)error;

+ (id)spidOauth2ErrorWithCode:(NSInteger)errorCode userInfo:(NSDictionary *)userInfo;

+ (id)spidApiErrorWithCode:(NSInteger)errorCode userInfo:(NSDictionary *)userInfo;

@end

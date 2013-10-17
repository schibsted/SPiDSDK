//
//  SPiDSDK.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 14/10/13.
//  Copyright (c) 2013 Mikael Lindström. All rights reserved.
//

#ifndef SPiDSDK_SPiDSDK_h
#define SPiDSDK_SPiDSDK_h

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
    
    SPiDAPIExceptionErrorCode = -1300
    
};


#endif

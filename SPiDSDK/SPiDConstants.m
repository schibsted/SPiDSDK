//
//  SPiDConstants.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/19/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDConstants.h"

NSString const *SPiDSKDVersion = @"2";

// OAuth 2.0 errors invalid_client_credentials
NSInteger const SPiDOAuth2RedirectURIMismatchErrorCode = -1000;
NSInteger const SPiDOAuth2UnauthorizedClientErrorCode = -1001;
NSInteger const SPiDOAuth2AccessDeniedErrorCode = -1002;
NSInteger const SPiDOAuth2InvalidRequestErrorCode = -1003;
NSInteger const SPiDOAuth2UnsupportedResponseTypeErrorCode = -1004;
NSInteger const SPiDOAuth2InvalidScopeErrorCode = -1005;
NSInteger const SPiDOAuth2InvalidGrantErrorCode = -1006;
NSInteger const SPiDOAuth2InvalidClientErrorCode = -1007;
// These to are replaced by "invalid_client" in draft 10 of OAuth 2.0
NSInteger const SPiDOAuth2InvalidClientIDErrorCode = -1008;
NSInteger const SPiDOAuth2InvalidClientCredentialsErrorCode = -1009;

// Protected resource errors
NSInteger const SPiDOAuth2InvalidTokenErrorCode = -1010;
NSInteger const SPiDOAuth2ExpiredTokenErrorCode = -1011;
NSInteger const SPiDOAuth2InsufficientScopeErrorCode = -1012;

// Grant type error
NSInteger const SPiDOAuth2UnsupportedGrantTypeErrorCode = -1020;
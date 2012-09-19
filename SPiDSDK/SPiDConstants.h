//
//  SPiDConstants.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/19/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>

// OAuth 2.0 errors
extern NSInteger const SPiDOAuth2RedirectURIMismatchErrorCode;
extern NSInteger const SPiDOAuth2InvalidClientErrorCode;
extern NSInteger const SPiDOAuth2UnauthorizedClientErrorCode;
extern NSInteger const SPiDOAuth2AccessDeniedErrorCode;
extern NSInteger const SPiDOAuth2InvalidRequestErrorCode;
extern NSInteger const SPiDOAuth2InvalidClientIDErrorCode;
extern NSInteger const SPiDOAuth2UnsupportedResponseTypeErrorCode;
extern NSInteger const SPiDOAuth2InvalidScopeErrorCode;
extern NSInteger const SPiDOAuth2InvalidGrantErrorCode;

// Protected resource errors
extern NSInteger const SPiDOAuth2InvalidTokenErrorCode;
extern NSInteger const SPiDOAuth2ExpiredTokenErrorCode;
extern NSInteger const SPiDOAuth2InsufficientScopeErrorCode;

// Error for trying to use a grant type that we haven't implemented
extern NSInteger const SPiDOAuth2UnsupportedGrantTypeErrorCode;
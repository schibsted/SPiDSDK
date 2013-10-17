//
//  NSError+SPiDError.m
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "NSError+SPiDError.h"
#import "SPiDClient.h"
#import "SPiDSDK.h"

NSString *const SPiDOAuth2ErrorDomain = @"SPiDOAuth2";
NSString *const SPiDApiErrorDomain = @"ApiException";

@implementation NSError (SPiDError)

+ (id)spidErrorFromJSONData:(NSDictionary *)dictionary {
    NSString *domain;
    NSDictionary *descriptions;
    NSInteger originalErrorCode;
    NSInteger errorCode;
    
    if ([[dictionary objectForKey:@"error"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *errorDict = [dictionary objectForKey:@"error"];
        domain = [errorDict objectForKey:@"type"];
        originalErrorCode = [[errorDict objectForKey:@"code"] integerValue];
        errorCode = [self getSPiDOAuth2ErrorCode:domain];
        if ([[errorDict objectForKey:@"description"] isKindOfClass:[NSDictionary class]]) {
            descriptions = [errorDict objectForKey:@"description"];
        } else {
            descriptions = [NSDictionary dictionaryWithObjectsAndKeys:[errorDict objectForKey:@"description"], @"error", nil];
        }
    } else {
        domain = [dictionary objectForKey:@"error"];
        descriptions = [NSDictionary dictionaryWithObjectsAndKeys:[dictionary objectForKey:@"error_description"], @"error", nil];
        originalErrorCode = [[dictionary objectForKey:@"error_code"] integerValue];
        errorCode = [self getSPiDOAuth2ErrorCode:domain];
    }
    
    if (descriptions.count == 0) {
        descriptions = [NSDictionary dictionaryWithObjectsAndKeys:domain, @"error", nil];
    }
    
    SPiDDebugLog("Received '%@' with code '%d' and description: %@", domain, originalErrorCode, [descriptions description]);
    NSError *error = [NSError errorWithDomain:domain code:errorCode userInfo:descriptions];
    return error;
}

+ (id)spidOauth2ErrorWithString:(NSString *)errorString {
    NSInteger errorCode = [self getSPiDOAuth2ErrorCode:errorString];
    NSDictionary *descriptions = [NSDictionary dictionaryWithObjectsAndKeys:errorString, @"error", nil];
    return [NSError errorWithDomain:SPiDOAuth2ErrorDomain code:errorCode userInfo:descriptions];
}

+ (id)spidOauth2ErrorWithCode:(NSInteger)errorCode userInfo:(NSDictionary *)userInfo {
    NSError *error = [NSError errorWithDomain:SPiDOAuth2ErrorDomain code:errorCode userInfo:userInfo];
    return error;
}

+ (id)spidApiErrorWithCode:(NSInteger)errorCode userInfo:(NSDictionary *)userInfo {
    NSError *error = [NSError errorWithDomain:SPiDApiErrorDomain code:errorCode userInfo:userInfo];
    return error;
}

+ (NSInteger)getSPiDOAuth2ErrorCode:(NSString *)errorString {
    NSInteger errorCode = 0;
    if ([errorString caseInsensitiveCompare:@"redirect_uri_mismatch"] == NSOrderedSame) {
        errorCode = SPiDOAuth2RedirectURIMismatchErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"unauthorized_client"] == NSOrderedSame) {
        errorCode = SPiDOAuth2UnauthorizedClientErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"access_denied"] == NSOrderedSame) {
        errorCode = SPiDOAuth2AccessDeniedErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"invalid_request"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidRequestErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"unsupported_response_type"] == NSOrderedSame) {
        errorCode = SPiDOAuth2UnsupportedResponseTypeErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"invalid_scope"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidScopeErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"invalid_grant"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidGrantErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"invalid_client"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidClientErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"invalid_client_id"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidClientIDErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"invalid_client_credentials"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidClientCredentialsErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"invalid_token"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidTokenErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"insufficient_scope"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InsufficientScopeErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"expired_token"] == NSOrderedSame) {
        errorCode = SPiDOAuth2ExpiredTokenErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"ApiException"] == NSOrderedSame) {
        errorCode = SPiDAPIExceptionErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"UserAbortedLogin"] == NSOrderedSame) {
        errorCode = SPiDUserAbortedLogin;
    } else if ([errorString caseInsensitiveCompare:@"unverified_user"] == NSOrderedSame) {
        errorCode = SPiDOAuth2UnverifiedUserErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"invalid_user_credentials"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidUserCredentialsErrorCode;
    } else if ([errorString caseInsensitiveCompare:@"unknown_user"] == NSOrderedSame) {
        errorCode = SPiDOAuth2UnknownUserErrorCode;
    }
    
    return errorCode;
}

@end


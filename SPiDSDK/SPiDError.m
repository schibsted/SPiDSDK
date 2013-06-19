//
//  NSError+SPiDError
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDError.h"
#import "SPiDClient.h"

@implementation SPiDError

+ (id)errorFromJSONData:(NSDictionary *)dictionary {
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
    SPiDError *error = [SPiDError errorWithDomain:domain code:errorCode userInfo:nil];
    error.descriptions = descriptions;
    return error;
}

+ (id)oauth2ErrorWithString:(NSString *)errorString {
    NSInteger errorCode = [self getSPiDOAuth2ErrorCode:errorString];
    NSDictionary *descriptions = [NSDictionary dictionaryWithObjectsAndKeys:errorString, @"error", nil];
    return [self oauth2ErrorWithCode:errorCode reason:errorString descriptions:descriptions];
}


+ (id)oauth2ErrorWithCode:(NSInteger)errorCode reason:(NSString *)reason descriptions:(NSDictionary *)descriptions {
    NSMutableDictionary *info = nil;
    if ([reason length] > 0) {
        info = [NSMutableDictionary dictionary];
        if ([reason length] > 0) [info setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    }
    SPiDError *error = [SPiDError errorWithDomain:@"SPiDOAuth2" code:errorCode userInfo:nil];
    error.descriptions = descriptions;
    return error;
}

+ (id)apiErrorWithCode:(NSInteger)errorCode reason:(NSString *)reason descriptions:(NSDictionary *)descriptions {
    NSMutableDictionary *info = nil;
    if ([reason length] > 0) {
        info = [NSMutableDictionary dictionary];
        if ([reason length] > 0) [info setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    }
    SPiDError *error = [SPiDError errorWithDomain:@"ApiException" code:errorCode userInfo:nil];
    error.descriptions = descriptions;
    return error;
}

+ (id)errorFromNSError:(NSError *)error {
    SPiDError *spidError = [SPiDError errorWithDomain:error.domain code:error.code userInfo:error.userInfo];
    spidError.descriptions = nil;
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
        errorCode = SPiDOAuth2InvalidClientIDErrorCode; // Replaced by "invalid_client" in draft 10 of oauth 2.0
    } else if ([errorString caseInsensitiveCompare:@"invalid_client_credentials"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidClientCredentialsErrorCode; // Replaced by "invalid_client" in draft 10 of oauth 2.0
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
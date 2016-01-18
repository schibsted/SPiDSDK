//
//  NSError+SPiDError
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "NSError+SPiD.h"
#import "SPiDClient.h"

@implementation NSError (SPiD)

+ (instancetype)sp_errorFromJSONData:(NSDictionary *)dictionary {
    NSString *domain;
    NSDictionary *descriptions;
    NSInteger originalErrorCode;
    NSInteger errorCode;

    if ([[dictionary objectForKey:@"error"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *errorDict = [dictionary objectForKey:@"error"];
        domain = [errorDict objectForKey:@"type"];
        originalErrorCode = [[errorDict objectForKey:@"code"] integerValue];
        errorCode = [self sp_OAuth2ErrorCodeFromDomain:domain andAPIErrorCode:originalErrorCode];
        if ([[errorDict objectForKey:@"description"] isKindOfClass:[NSDictionary class]]) {
            descriptions = [errorDict objectForKey:@"description"];
        } else {
            descriptions = [NSDictionary dictionaryWithObjectsAndKeys:[errorDict objectForKey:@"description"], @"error", nil];
        }
    } else {
        domain = [dictionary objectForKey:@"error"];
        descriptions = [NSDictionary dictionaryWithObjectsAndKeys:[dictionary objectForKey:@"error_description"], @"error", nil];
        originalErrorCode = [[dictionary objectForKey:@"error_code"] integerValue];
        errorCode = [self sp_OAuth2ErrorCodeFromDomain:domain andAPIErrorCode:originalErrorCode];
    }

    if (descriptions.count == 0) {
        descriptions = [NSDictionary dictionaryWithObjectsAndKeys:domain, @"error", nil];
    }

    SPiDDebugLog("Received '%@' with code '%ld' and description: %@", domain, originalErrorCode, [descriptions description]);
    return [NSError errorWithDomain:domain code:errorCode userInfo:descriptions];
}

+ (instancetype)sp_oauth2ErrorWithString:(NSString *)errorString {
    NSInteger errorCode = [self sp_OAuth2ErrorCodeFromDomain:errorString andAPIErrorCode:0];
    NSDictionary *descriptions = [NSDictionary dictionaryWithObjectsAndKeys:errorString, @"error", nil];
    return [self sp_oauth2ErrorWithCode:errorCode reason:errorString descriptions:descriptions];
}

+ (instancetype)sp_oauth2ErrorWithCode:(NSInteger)errorCode reason:(NSString *)reason descriptions:(NSDictionary *)descriptions {
    NSMutableDictionary *info = nil;
    if ([reason length] > 0) {
        info = [NSMutableDictionary dictionary];
        if ([reason length] > 0) [info setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    }
    return [NSError errorWithDomain:@"SPiDOAuth2" code:errorCode userInfo:descriptions];
}

+ (instancetype)sp_apiErrorWithCode:(NSInteger)errorCode reason:(NSString *)reason descriptions:(NSDictionary *)descriptions {
    NSMutableDictionary *info = nil;
    if ([reason length] > 0) {
        info = [NSMutableDictionary dictionary];
        if ([reason length] > 0) [info setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    }
    return [NSError errorWithDomain:@"ApiException" code:errorCode userInfo:descriptions];
}

+ (NSInteger)sp_OAuth2ErrorCodeFromDomain:(NSString *)errorDomain andAPIErrorCode:(NSInteger)apiError {
    NSInteger errorCode = 0;
    if ([errorDomain caseInsensitiveCompare:@"redirect_uri_mismatch"] == NSOrderedSame) {
        errorCode = SPiDOAuth2RedirectURIMismatchErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"unauthorized_client"] == NSOrderedSame) {
        errorCode = SPiDOAuth2UnauthorizedClientErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"access_denied"] == NSOrderedSame) {
        errorCode = SPiDOAuth2AccessDeniedErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"invalid_request"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidRequestErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"unsupported_response_type"] == NSOrderedSame) {
        errorCode = SPiDOAuth2UnsupportedResponseTypeErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"invalid_scope"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidScopeErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"invalid_grant"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidGrantErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"invalid_client"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidClientErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"invalid_client_id"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidClientIDErrorCode; // Replaced by "invalid_client" in draft 10 of oauth 2.0
    } else if ([errorDomain caseInsensitiveCompare:@"invalid_client_credentials"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidClientCredentialsErrorCode; // Replaced by "invalid_client" in draft 10 of oauth 2.0
    } else if ([errorDomain caseInsensitiveCompare:@"invalid_token"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidTokenErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"insufficient_scope"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InsufficientScopeErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"expired_token"] == NSOrderedSame) {
        errorCode = SPiDOAuth2ExpiredTokenErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"ApiException"] == NSOrderedSame) {
        if(apiError == 302) {
            errorCode = SPiDAPIExceptionExistingUser;
        } else {
            errorCode = SPiDAPIExceptionErrorCode;
        }
    } else if ([errorDomain caseInsensitiveCompare:@"UserAbortedLogin"] == NSOrderedSame) {
        errorCode = SPiDUserAbortedLogin;
    } else if ([errorDomain caseInsensitiveCompare:@"unverified_user"] == NSOrderedSame) {
        errorCode = SPiDOAuth2UnverifiedUserErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"invalid_user_credentials"] == NSOrderedSame) {
        errorCode = SPiDOAuth2InvalidUserCredentialsErrorCode;
    } else if ([errorDomain caseInsensitiveCompare:@"unknown_user"] == NSOrderedSame) {
        errorCode = SPiDOAuth2UnknownUserErrorCode;
    }

    return errorCode;
}

@end

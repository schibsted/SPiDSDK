//
//  NSError+SPiDError
//  SPiDSDK
//
//  Created by mikaellindstrom on 10/2/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "NSError+SPiDError.h"

@implementation NSError (SPiDError)

+ (NSError *)errorFromJSONData:(NSDictionary *)dictionary {
    NSString *errorString = [dictionary objectForKey:@"error"];
    NSString *errorDescription = [dictionary objectForKey:@"error_description"];
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
    }

    return [self oauth2ErrorWithCode:errorCode description:errorDescription reason:errorString];
}

+ (NSError *)oauth2ErrorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason {
    NSMutableDictionary *info = nil;
    if ([description length] > 0 || [reason length] > 0) {
        info = [NSMutableDictionary dictionaryWithCapacity:2];
        if ([description length] > 0) [info setObject:description forKey:NSLocalizedDescriptionKey];
        if ([reason length] > 0) [info setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    }
    return [self errorWithDomain:@"SPiDOAuth2" code:code userInfo:info];
}

+ (NSError *)apiErrorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason {
    return nil;
}

@end
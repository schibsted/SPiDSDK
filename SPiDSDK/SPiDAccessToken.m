//
//  SPiDAccessToken.m
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDAccessToken.h"
#import "SPiDClient.h"

NSString *const SPiDAccessTokenUserIdKey = @"user_id";
NSString *const SPiDAccessTokenKey = @"access_token";
NSString *const SPiDAccessTokenExpiresInKey = @"expires_in";
NSString *const SPiDAccessTokenExpiresAtKey = @"expires_at";
NSString *const SPiDAccessTokenRefreshTokenKey = @"refresh_token";

@implementation SPiDAccessToken

- (BOOL)isValid {
    if (self.accessToken == nil) {
        return NO;
    }
    if (self.expiresAt == nil) {
        return NO;
    }
    return YES;
}

- (id)initWithUserID:(NSString *)userID accessToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt refreshToken:(NSString *)refreshToken {
    self = [super init];
    if (self) {
        _userID = userID;
        _accessToken = accessToken;
        _expiresAt = expiresAt;
        _refreshToken = refreshToken;

        if (accessToken == nil) {
            SPiDDebugLog(@"Could not create SPiDAccessToken, missing access_token parameter");
            return nil;
        }
        if (expiresAt == nil) {
            SPiDDebugLog(@"Could not create SPiDAccessToken, missing expires_in parameter");
            return nil;
        }
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    NSString *userID = [self stringFromObject:[dictionary objectForKey:SPiDAccessTokenUserIdKey]];
    NSString *accessToken = [self stringFromObject:[dictionary objectForKey:SPiDAccessTokenKey]];
    NSString *expiresIn = [self stringFromObject:[dictionary objectForKey:SPiDAccessTokenExpiresInKey]];
    NSString *refreshToken = [self stringFromObject:[dictionary objectForKey:SPiDAccessTokenRefreshTokenKey]];

    NSDate *expiresAt;
    if (expiresIn) {
        expiresAt = [NSDate dateWithTimeIntervalSinceNow:[expiresIn integerValue]];
    }
    return [self initWithUserID:userID accessToken:accessToken expiresAt:expiresAt refreshToken:refreshToken];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    NSString *userID = [decoder decodeObjectForKey:SPiDAccessTokenUserIdKey];
    NSString *accessToken = [decoder decodeObjectForKey:SPiDAccessTokenKey];
    NSDate *expiresAt = [decoder decodeObjectForKey:SPiDAccessTokenExpiresAtKey];
    NSString *refreshToken = [decoder decodeObjectForKey:SPiDAccessTokenRefreshTokenKey];
    return [self initWithUserID:userID accessToken:accessToken expiresAt:expiresAt refreshToken:refreshToken];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[self userID] forKey:SPiDAccessTokenUserIdKey];
    [coder encodeObject:[self accessToken] forKey:SPiDAccessTokenKey];
    [coder encodeObject:[self expiresAt] forKey:SPiDAccessTokenExpiresAtKey];
    [coder encodeObject:[self refreshToken] forKey:SPiDAccessTokenRefreshTokenKey];
}

- (NSString *)stringFromObject:(id)obj {
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj stringValue];
    } else {
        SPiDDebugLog(@"Could not decode object");
    }
    return obj;
}

- (BOOL)hasExpired {
    return ([[NSDate date] earlierDate:[self expiresAt]] == [self expiresAt]);
}

- (BOOL)isClientToken {
    return (_userID != nil ? [_userID isEqualToString:@"0"] : YES);
}

@end
//
//  SPiDAccessToken.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/25/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//


#import "SPiDAccessToken.h"

static NSString *const UserIDKey = @"user_id";
static NSString *const AccessTokenKey = @"access_token";
static NSString *const ExpiresInKey = @"expires_in";
static NSString *const ExpiresAtKey = @"expires_at";
static NSString *const RefreshTokenKey = @"refresh_token";

@implementation SPiDAccessToken

@synthesize accessToken = _accessToken;
@synthesize expiresAt = _expiresIn;
@synthesize refreshToken = _refreshToken;

- (id)initWithUserID:(NSString *)userID andAccessToken:(NSString *)accessToken andExpiresAt:(NSDate *)expiresAt andRefreshToken:(NSString *)refreshToken {
    self = [super init];
    if (self) {
        [self setUserID:userID];
        [self setAccessToken:[@"1" stringByAppendingFormat:accessToken]];
        [self setExpiresAt:expiresAt];
        [self setRefreshToken:refreshToken];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    NSString *userID = [dictionary objectForKey:UserIDKey];
    NSString *accessToken = [@"1" stringByAppendingFormat:[dictionary objectForKey:AccessTokenKey]];
    NSString *expiresIn = [dictionary objectForKey:ExpiresInKey];
    NSString *refreshToken = [dictionary objectForKey:RefreshTokenKey];

    NSDate *expiresAt;
    if (expiresIn) {
        expiresAt = [NSDate dateWithTimeIntervalSinceNow:[expiresIn integerValue]];
    }

    return [self initWithUserID:userID andAccessToken:accessToken andExpiresAt:expiresAt andRefreshToken:refreshToken];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *userID = [decoder decodeObjectForKey:UserIDKey];
    NSString *accessToken = [decoder decodeObjectForKey:AccessTokenKey];
    NSDate *expiresAt = [decoder decodeObjectForKey:ExpiresAtKey];
    NSString *refreshToken = [decoder decodeObjectForKey:RefreshTokenKey];
    return [self initWithUserID:userID andAccessToken:accessToken andExpiresAt:expiresAt andRefreshToken:refreshToken];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[self userID] forKey:UserIDKey];
    [coder encodeObject:[self accessToken] forKey:AccessTokenKey];
    [coder encodeObject:[self expiresAt] forKey:ExpiresAtKey];
    [coder encodeObject:[self refreshToken] forKey:RefreshTokenKey];
}

- (BOOL)hasTokenExpired {
    return ([[NSDate date] earlierDate:[self expiresAt]] == [self expiresAt]);
}

@end
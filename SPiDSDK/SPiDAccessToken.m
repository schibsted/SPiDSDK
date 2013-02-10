//
//  SPiDAccessToken.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/25/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//


#import "SPiDAccessToken.h"
#import "SPiDClient.h"

static NSString *const UserIDKey = @"user_id";
static NSString *const AccessTokenKey = @"access_token";
static NSString *const ExpiresInKey = @"expires_in";
static NSString *const ExpiresAtKey = @"expires_at";
static NSString *const RefreshTokenKey = @"refresh_token";

@implementation SPiDAccessToken

@synthesize accessToken = _accessToken;
@synthesize expiresAt = _expiresIn;
@synthesize refreshToken = _refreshToken;

- (id)initWithUserID:(NSString *)userID accessToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt refreshToken:(NSString *)refreshToken {
    self = [super init];
    if (self) {
        [self setUserID:userID];
        [self setAccessToken:accessToken];
        [self setExpiresAt:expiresAt];
        [self setRefreshToken:refreshToken];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    NSString *userID = [self stringFromObject:[dictionary objectForKey:UserIDKey]];
    NSString *accessToken = [self stringFromObject:[dictionary objectForKey:AccessTokenKey]];
    NSString *expiresIn = [self stringFromObject:[dictionary objectForKey:ExpiresInKey]];
    NSString *refreshToken = [self stringFromObject:[dictionary objectForKey:RefreshTokenKey]];

    NSDate *expiresAt;
    if (expiresIn) {
        expiresAt = [NSDate dateWithTimeIntervalSinceNow:[expiresIn integerValue]];
    }
    return [self initWithUserID:userID accessToken:accessToken expiresAt:expiresAt refreshToken:refreshToken];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *userID = [decoder decodeObjectOfClass:[NSString class] forKey:UserIDKey];
    NSString *accessToken = [decoder decodeObjectOfClass:[NSString class] forKey:AccessTokenKey];
    NSDate *expiresAt = [decoder decodeObjectOfClass:[NSDate class] forKey:ExpiresAtKey];
    NSString *refreshToken = [decoder decodeObjectOfClass:[NSString class] forKey:RefreshTokenKey];
    return [self initWithUserID:userID accessToken:accessToken expiresAt:expiresAt refreshToken:refreshToken];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[self userID] forKey:UserIDKey];
    [coder encodeObject:[self accessToken] forKey:AccessTokenKey];
    [coder encodeObject:[self expiresAt] forKey:ExpiresAtKey];
    [coder encodeObject:[self refreshToken] forKey:RefreshTokenKey];
}

- (NSString *)stringFromObject:(id)obj {
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj stringValue];
    } else {
        SPiDDebugLog(@"Warning....");
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
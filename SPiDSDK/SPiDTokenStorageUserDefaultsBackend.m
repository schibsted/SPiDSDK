//
//  SPiDTokenStorageUserDefaultsBackend.m
//  SPiDSDK
//
//  Created by Daniel Lazarenko on 07/03/2017.
//

#import "SPiDTokenStorageUserDefaultsBackend.h"
#import "SPiDTokenStorage.h"
#import "SPiDAccessToken.h"

static NSString *const SPiDAccessTokenUserIdKey = @"user_id";
static NSString *const SPiDAccessTokenKey = @"access_token";
static NSString *const SPiDAccessTokenExpiresAtKey = @"expires_at";
static NSString *const SPiDAccessTokenRefreshTokenKey = @"refresh_token";

static NSString *const SPiDAccessTokenUserDefaultsPrefix = @"SPiD.";

#define DICT_KEY [SPiDAccessTokenUserDefaultsPrefix stringByAppendingString:identifier]


@implementation SPiDTokenStorageUserDefaultsBackend
{
    NSUserDefaults *_defaults;
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)defaults
{
    self = [super init];
    if (self == nil) return nil;
    _defaults = defaults;
    return self;
}

- (SPiDAccessToken *)accessTokenForIdentifier:(NSString *)identifier
{
    NSDictionary<NSString *, id> *dict = [_defaults dictionaryForKey:DICT_KEY];
    NSString *userID = dict[SPiDAccessTokenUserIdKey];
    NSString *accessToken = dict[SPiDAccessTokenKey];
    NSNumber *expiresAtNum = dict[SPiDAccessTokenExpiresAtKey];
    NSDate *expiresAt = nil;
    if (expiresAtNum != nil) {
        expiresAt = [NSDate dateWithTimeIntervalSince1970:[expiresAtNum integerValue]];
    }
    NSString *refreshToken = dict[SPiDAccessTokenRefreshTokenKey];
    return [[SPiDAccessToken alloc] initWithUserID:userID accessToken:accessToken
                                         expiresAt:expiresAt refreshToken:refreshToken];
}

- (BOOL)storeAccessTokenWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier
{
    return [self updateAccessTokenWithValue:accessToken forIdentifier:identifier];
}

- (BOOL)updateAccessTokenWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier
{
    NSMutableDictionary<NSString *, id> *dict = [NSMutableDictionary new];
    if (accessToken.userID) {
        dict[SPiDAccessTokenUserIdKey] = accessToken.userID;
    }
    if (accessToken.accessToken) {
        dict[SPiDAccessTokenKey] = accessToken.accessToken;
    }
    if (accessToken.expiresAt) {
        NSInteger expiresAtInt = (NSInteger)[accessToken.expiresAt timeIntervalSince1970];
        dict[SPiDAccessTokenExpiresAtKey] = @(expiresAtInt);
    }
    if (accessToken.refreshToken) {
        dict[SPiDAccessTokenRefreshTokenKey] = accessToken.refreshToken;
    }
    [_defaults setObject:dict forKey:DICT_KEY];
    return YES;
}

- (void)removeAccessTokenForIdentifier:(NSString *)identifier
{
    [_defaults removeObjectForKey:DICT_KEY];
}

@end

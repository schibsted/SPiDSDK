//
//  SPiDTokenStorageKeychainBackend.m
//  SPiDSDK
//
//  Created by Daniel Lazarenko on 07/03/2017.
//

#import "SPiDTokenStorageKeychainBackend.h"
#import "SPiDKeychainWrapper.h"

@implementation SPiDTokenStorageKeychainBackend

- (SPiDAccessToken *)accessTokenForIdentifier:(NSString *)identifier
{
    return [SPiDKeychainWrapper accessTokenFromKeychainForIdentifier:identifier];
}

- (BOOL)storeAccessTokenWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier
{
    return [SPiDKeychainWrapper storeInKeychainAccessTokenWithValue:accessToken forIdentifier:identifier];
}

- (BOOL)updateAccessTokenWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier
{
    return [SPiDKeychainWrapper updateAccessTokenInKeychainWithValue:accessToken forIdentifier:identifier];
}

- (void)removeAccessTokenForIdentifier:(NSString *)identifier
{
    [SPiDKeychainWrapper removeAccessTokenFromKeychainForIdentifier:identifier];
}

@end

//
//  SPiDTokenStorage.h
//  SPiDSDK
//
//  Created by Daniel Lazarenko on 07/03/2017.
//

#import <Foundation/Foundation.h>

@class SPiDAccessToken;

@protocol SPiDTokenStorageBackend <NSObject>

@required
- (SPiDAccessToken *)accessTokenForIdentifier:(NSString *)identifier;
- (BOOL)storeAccessTokenWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier;
- (BOOL)updateAccessTokenWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier;
- (void)removeAccessTokenForIdentifier:(NSString *)identifier;

@end


typedef NS_ENUM(NSUInteger, SPiDTokenStorageBackendType) {
    SPiDTokenStorageBackendTypeKeychain = 1,
    SPiDTokenStorageBackendTypeUserDefaults,
};


@interface SPiDTokenStorage : NSObject

- (instancetype)initWithReadBackendTypes:(NSArray<NSNumber *> *)readBackendTypes
                       writeBackendTypes:(NSArray<NSNumber *> *)writeBackendTypes;

- (instancetype)initWithReadBackendTypes:(NSArray<NSNumber *> *)readBackendTypes
                       writeBackendTypes:(NSArray<NSNumber *> *)writeBackendTypes
                                backends:(NSDictionary<NSNumber *, id<SPiDTokenStorageBackend>> *)backends;

- (SPiDAccessToken *)loadAccessTokenAndReplicate;
- (BOOL)storeAccessTokenWithValue:(SPiDAccessToken *)accessToken;
- (BOOL)updateAccessTokenWithValue:(SPiDAccessToken *)accessToken;
- (void)removeAccessToken;

@end

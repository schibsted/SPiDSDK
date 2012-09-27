//
//  SPiDKeychainWrapper.h
//  SPiDSDK
//
//  Created by mikaellindstrom on 9/27/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDAccessToken.h"

@interface SPiDKeychainWrapper : NSObject
+ (SPiDAccessToken *)getAccessTokenFromKeychainForIdentifier:(NSString *)identifier;

+ (BOOL)storeInKeychainAccessTokenWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier;

+ (BOOL)updateAccessTokenInKeychainWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier;

+ (void)removeAccessTokenFromKeychainForIdentifier:(NSString *)identifier;

@end
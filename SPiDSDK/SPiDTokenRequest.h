//
//  SPiDTokenRequest
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/21/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDRequest.h"

@interface SPiDTokenRequest : SPiDRequest

+ (SPiDTokenRequest *)clientTokenRequestWithCompletionHandler:(void (^)(NSError *error))completionHandler;

+ (SPiDTokenRequest *)userTokenRequestWithUsername:(NSString *)username andPassword:(NSString *)password andAuthCompletionHandler:(void (^)(NSError *error))authCompletionHandler;

+ (SPiDTokenRequest *)userTokenRequestWithFacebookAppID:(NSString *)appId andAccessToken:(NSString *)facebookToken andExpirationDate:(NSDate *)expirationDate andAuthCompletionHandler:(void (^)(NSError *))completionHandler;
@end
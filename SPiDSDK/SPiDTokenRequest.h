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

+ (SPiDTokenRequest *)clientTokenRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

+ (SPiDTokenRequest *)userTokenRequestWithUsername:(NSString *)username andPassword:(NSString *)password andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

@end
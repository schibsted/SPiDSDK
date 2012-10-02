//
//  SPiDAuthorizationRequest.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/21/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDConstants.h"
#import "SPiDClient.h"
#import "SPiDAccessToken.h"

@interface SPiDAuthorizationRequest : NSObject <NSURLConnectionDelegate> {
@private
    NSString *code;
    NSMutableData *receivedData;

    void (^completionHandler)(SPiDAccessToken *accessToken, NSError *error);

}

- (id)initWithCompletionHandler:(void (^)(SPiDAccessToken *accessToken, NSError *error))handler;

- (void)authorize;

- (void)refreshWithRefreshToken:(SPiDAccessToken *)accessToken;

- (void)logoutWithAccessToken:(SPiDAccessToken *)accessToken;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)softLogoutWithAccessToken:(SPiDAccessToken *)accessToken;
@end
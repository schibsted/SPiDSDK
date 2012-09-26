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

// Not accessible outside SDK
typedef void (^SPiDInternalAuthorizationCompletionHandler)(SPiDAccessToken *accessToken, NSError *error);

@interface SPiDAuthorizationRequest : NSObject <NSURLConnectionDelegate> {
@private
    NSString *code;
    NSMutableData *receivedData;

    SPiDInternalAuthorizationCompletionHandler completionHandler;
}

- (id)initWithCompletionHandler:(SPiDInternalAuthorizationCompletionHandler)handler;

- (void)authorize;

- (id)initRefreshWithAccessToken:(SPiDAccessToken *)accessToken andCompletionHandler:(SPiDInternalAuthorizationCompletionHandler)handler;

- (BOOL)handleOpenURL:(NSURL *)url;

@end
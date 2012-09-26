//
//  SPiDRequest.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/17/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDClient.h"

@class SPiDAccessToken;

@interface SPiDRequest : NSObject <NSURLConnectionDelegate> {
@private
    NSURL *url;
    NSString *httpMethod;
    NSString *httpBody;
    NSMutableData *receivedData;
    SPiDCompletionHandler completionHandler;
}

- (void)doAuthenticatedSPiDGetRequestWithURL:(NSURL *)url;

- (void)doRequestWithAccessToken:(SPiDAccessToken *)accessToken;


- (id)initGetRequestWithPath:(NSString *)requestPath andCompletionHandler:(SPiDCompletionHandler)handler;

- (id)initPostRequestWithPath:(NSString *)requestPath andHTTPBody:(NSString *)body andCompletionHandler:(SPiDCompletionHandler)handler;

- (id)initRequestWithPath:(NSString *)requestPath andHTTPMethod:(NSString *)method andHTTPBody:(NSString *)body andCompletionHandler:(SPiDCompletionHandler)handler;


- (void)doAuthenticatedLogoutRequestWithCompletionHandler:(SPiDCompletionHandler)handler;

- (void)doAuthenticatedLoginsRequestWithCompletionHandler:(SPiDCompletionHandler)handler andUserID:(NSString *)userID;

// TODO: Should have retry method

@end
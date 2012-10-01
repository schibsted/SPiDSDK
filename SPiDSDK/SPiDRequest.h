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
@class SPiDResponse;

@interface SPiDRequest : NSObject <NSURLConnectionDelegate> {
@private
    NSURL *url;
    NSString *httpMethod;
    NSString *httpBody;
    NSMutableData *receivedData;

    void (^completionHandler)(SPiDResponse *response);

}

- (void)startRequestWithAccessToken:(SPiDAccessToken *)accessToken;


- (id)initGetRequestWithPath:(NSString *)requestPath andCompletionHandler:(void (^)(SPiDResponse *response))handler;

- (id)initPostRequestWithPath:(NSString *)requestPath andHTTPBody:(NSString *)body andCompletionHandler:(void (^)(SPiDResponse *response))handler;

- (id)initRequestWithPath:(NSString *)requestPath andHTTPMethod:(NSString *)method andHTTPBody:(NSString *)body andCompletionHandler:(void (^)(SPiDResponse *response))handler;

// TODO: Should have retry method

@end
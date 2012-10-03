//
//  SPiDRequest.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/17/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDClient.h"

/** `SPiDRequest` handles a request against SPiD.

 An instance of `SPiDClient` is setup for each request to SPiD from `SPiDClient`
*/

static NSInteger const MaxRetryAttempts = 2; //TODO: This should not be hardcoded

@class SPiDAccessToken;
@class SPiDResponse;

@interface SPiDRequest : NSObject <NSURLConnectionDelegate>

@property(nonatomic) NSInteger retryCount;

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** Creates a SPiD GET request

 @param requestPath API path for GET request
 @param handler Completion handler run after request is finished
 @return SPiDRequest
*/
- (id)initGetRequestWithPath:(NSString *)requestPath andCompletionHandler:(void (^)(SPiDResponse *response))handler;

/** Creates a SPiD POST request

 @param requestPath API path for POST request
 @param body HTTP body
 @param handler Completion handler run after request is finished
 @return SPiDRequest
*/
- (id)initPostRequestWithPath:(NSString *)requestPath andHTTPBody:(NSString *)body andCompletionHandler:(void (^)(SPiDResponse *response))handler;

/** Creates a SPiD request

 @param requestPath API path for request
 @param method HTTP method for the request
 @param body HTTP body, used it method is POST
 @param handler Completion handler run after request is finished
 @return SPiDRequest
*/
- (id)initRequestWithPath:(NSString *)requestPath andHTTPMethod:(NSString *)method andHTTPBody:(NSString *)body andCompletionHandler:(void (^)(SPiDResponse *response))handler;

/** Runs the request

 @param accessToken The access token to use with the request
*/
- (void)startRequestWithAccessToken:(SPiDAccessToken *)accessToken;

// TODO: Should have retry method

@end
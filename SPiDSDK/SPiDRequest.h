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

@interface SPiDRequest : NSObject <NSURLConnectionDelegate> {
@protected
    NSURL *url;
    NSString *httpMethod;
    NSString *httpBody;
    NSMutableData *receivedData;

    void (^completionHandler)(SPiDResponse *response);

}

@property(nonatomic) NSInteger retryCount;

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------


+ (SPiDRequest *)getRequestWithPath:(NSString *)requestPath andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

+ (SPiDRequest *)postRequestWithPath:(NSString *)requestPath andHTTPBody:(NSDictionary *)body andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

+ (SPiDRequest *)requestWithPath:(NSString *)requestPath andHTTPMethod:(NSString *)method andHTTPBody:(NSDictionary *)body andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Creates a SPiD GET request

 @param requestPath API path for GET request
 @param completionHandler Completion handler run after request is finished
 @return SPiDRequest
*/
- (id)initGetRequestWithPath:(NSString *)requestPath andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Creates a SPiD POST request

 @param requestPath API path for POST request
 @param body HTTP body
 @param completionHandler Completion handler run after request is finished
 @return SPiDRequest
*/
- (id)initPostRequestWithPath:(NSString *)requestPath andHTTPBody:(NSDictionary *)body andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Creates a SPiD request

 @param requestPath API path for request
 @param method HTTP method for the request
 @param body HTTP body, used it method is POST
 @param completionHandler Completion handler run after request is finished
 @return SPiDRequest
*/
- (id)initRequestWithPath:(NSString *)requestPath andHTTPMethod:(NSString *)method andHTTPBody:(NSDictionary *)body andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Runs the request

 @param accessToken The access token to use with the request
*/
- (void)startRequestWithAccessToken:(SPiDAccessToken *)accessToken;

- (void)startRequest;

// TODO: Should have retry method

@end
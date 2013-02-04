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
@private
    NSURL *_url;
    NSString *_httpMethod;
    NSString *_httpBody;

    void (^_completionHandler)(SPiDResponse *response);

@protected
    NSMutableData *_receivedData;
}

@property(nonatomic) NSInteger retryCount;

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** Creates a SPiD GET request

 @param requestPath API path for GET request e.g. /user
 @param _completionHandler Completion handler run after request is finished
 @return SPiDRequest
*/
+ (SPiDRequest *)apiGetRequestWithPath:(NSString *)requestPath andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Creates a SPiD POST request

 @param requestPath API path for POST request e.g. /user
 @param body HTTP body
 @param _completionHandler Completion handler run after request is finished
 @return SPiDRequest
*/
+ (SPiDRequest *)apiPostRequestWithPath:(NSString *)requestPath andHTTPBody:(NSDictionary *)body andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Creates a SPiD request

 @param requestPath API path for request
 @param method HTTP method for the request
 @param body HTTP body, used it method is POST
 @param _completionHandler Completion handler run after request is finished
 @return SPiDRequest
*/
+ (SPiDRequest *)requestWithPath:(NSString *)requestPath andHTTPMethod:(NSString *)method andHTTPBody:(NSDictionary *)body andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Runs the request

 @param accessToken The access token to use with the request
*/
- (void)startRequestWithAccessToken:(SPiDAccessToken *)accessToken;

- (void)startRequest;

@end
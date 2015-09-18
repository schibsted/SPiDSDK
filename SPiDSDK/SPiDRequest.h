//
//  SPiDRequest.h
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDClient.h"

/** `SPiDRequest` handles a request against SPiD. */

//TODO: static NSInteger const MaxRetryAttempts = 2;

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

/** Creates a GET `SPiDRequest`

 @param requestPath API path for GET request e.g. /user
 @param completionHandler Completion handler run after request is finished, will be called on the main thread.
 @return `SPiDRequest`
*/
+ (instancetype)apiGetRequestWithPath:(NSString *)requestPath completionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Creates a POST `SPiDRequest`

 @param requestPath API path for POST request e.g. /user
 @param body The HTTP body
 @param completionHandler Completion handler run after request is finished, will be called on the main thread.
 @return `SPiDRequest`
*/
+ (instancetype)apiPostRequestWithPath:(NSString *)requestPath body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Creates a `SPiDRequest`

 @param requestPath API path for request
 @param method HTTP method for the request
 @param body HTTP body, used if method is POST
 @param completionHandler Completion handler run after request is finished, will be called on the main thread.
 @return `SPiDRequest`
*/
+ (instancetype)requestWithPath:(NSString *)requestPath method:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Runs the request with the current access token */
- (void)startRequestWithAccessToken; //TODO rename

/** Runs the request without access token */
- (void)startRequest;


@end
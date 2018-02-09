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

NS_ASSUME_NONNULL_BEGIN

@interface SPiDRequest : NSObject

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong, readonly) NSString *HTTPMethod;
@property (nonatomic, strong, readonly) NSString *HTTPBody;
@property (nonatomic, assign) NSInteger retryCount;

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** Creates a GET `SPiDRequest`

 @param requestPath API path for GET request e.g. /user
 @param completionHandler Completion handler run after request is finished, will be called on the main thread.
 @return `SPiDRequest`
*/
+ (instancetype)apiGetRequestWithPath:(NSString *)requestPath completionHandler:(void (^)(SPiDResponse * response))completionHandler;

/** Creates a POST `SPiDRequest`

 @param requestPath API path for POST request e.g. /user
 @param body The HTTP body
 @param completionHandler Completion handler run after request is finished, will be called on the main thread.
 @return `SPiDRequest`
*/
+ (instancetype)apiPostRequestWithPath:(NSString *)requestPath body:(nullable NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Creates a `SPiDRequest`

 @param requestPath API path for request
 @param method HTTP method for the request
 @param body HTTP body, used if method is POST
 @param completionHandler Completion handler run after request is finished, will be called on the main thread.
 @return `SPiDRequest`
*/
+ (instancetype)requestWithPath:( NSString *)requestPath method:(nullable NSString *)method body:(nullable NSDictionary *)body completionHandler:(void (^ __nullable)(SPiDResponse * response))completionHandler;

/** Runs the request with the current access token */
- (void)startRequestWithAccessToken; //TODO rename

/** Runs the request without access token */
- (void)start;

/** Runs a SPiDRequest for a given NSURLRequest */
- (void)startWithRequest:(NSURLRequest *)request;

@end

NS_ASSUME_NONNULL_END

//
//  SPiDTokenRequest
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class SPiDAccessToken;

/** `SPiDTokenRequest` handles a token request against SPiD. */

@interface SPiDTokenRequest : SPiDRequest

///---------------------------------------------------------------------------------------
/// @name Public Methods
///---------------------------------------------------------------------------------------

/** Creates a client token request

 @param completionHandler Called on token request completion or error
 @return The token request or nil if JWT could not be created
*/
+ (nullable instancetype)clientTokenRequestWithCompletionHandler:(nullable void (^)(NSError * __nullable))completionHandler;

/** Creates a user token request with authorization code

 @param code The authorization code
 @param completionHandler Called on token request completion or error
 @return The token request or nil if JWT could not be created
*/
+ (nullable instancetype)userTokenRequestWithCode:(NSString *)code completionHandler:(void (^)(NSError * __nullable))completionHandler;

/** Creates a user token request with user credentials

 @param username The username
 @param password The password
 @param completionHandler Called on token request completion or error
 @return The token request or nil if JWT could not be created
*/
+ (nullable instancetype)userTokenRequestWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(NSError * __nullable error))completionHandler;

/** Creates a JWT facebook token request

 @param appId Facebook appID
 @param facebookToken Facebook access token
 @param expirationDate Expiration date for the facebook token
 @param completionHandler Called on token request completion or error
 @return The token request or nil if JWT could not be created
*/
+ (nullable instancetype)userTokenRequestWithFacebookAppID:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate completionHandler:(void (^)(NSError * __nullable))completionHandler;

/** Creates a token refresh token request with the current access token

 @param completionHandler Called on token request completion or error
 @return The token request or nil if refresh token is missing
*/
+ (nullable instancetype)refreshTokenRequestWithCompletionHandler:(void (^)(NSError * __nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END

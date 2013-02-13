//
//  SPiDTokenRequest
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDRequest.h"

@interface SPiDTokenRequest : SPiDRequest

/** Creates a client token request

 @param completionHandler
 @return The token request or nil if JWT could not be created
*/
+ (SPiDTokenRequest *)clientTokenRequestWithCompletionHandler:(void (^)(NSError *error))completionHandler;

/** Creates a user token request with authorization code

 @param code
 @return The token request or nil if JWT could not be created
*/
+ (SPiDTokenRequest *)userTokenRequestWithCode:(NSString *)code authCompletionHandler:(void (^)(NSError *))authCompletionHandler;

/** Creates a user token request with user credentials

 @param username
 @param password
 @return The token request or nil if JWT could not be created
*/
+ (SPiDTokenRequest *)userTokenRequestWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(NSError *error))completionHandler;

/** Creates a JWT facebook token request

 @param appId
 @param facebookToken
 @param expirationDate
 @param completionHandler
 @return The token request or nil if JWT could not be created
*/
+ (SPiDTokenRequest *)userTokenRequestWithFacebookAppID:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate completionHandler:(void (^)(NSError *))completionHandler;

/** Creates a token refresh token request

 @param accessToken Access token to refresh
 @return The token request or nil if refresh token is missing
*/
+ (SPiDTokenRequest *)refreshTokenRequestWithCompletionHandler:(void (^)(NSError *))completionHandler;

@end
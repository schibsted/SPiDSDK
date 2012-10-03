//
//  SPiDAuthorizationRequest.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/21/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDClient.h"
#import "SPiDAccessToken.h"

/** Authorization class for SPiD
 `SPiDAuthorizationRequest` takes care of all request regarding OAuth 2.0 autorization.

 When a authorization request is in progress, all other requests are queued waiting for request completetion.
 */

@interface SPiDAuthorizationRequest : NSObject <NSURLConnectionDelegate>

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** Creates a `SPiDAuthorizationRequest` and and setups completionHandler
 
 @param completionHandler Completion handler that will be run after request is completed
 @return Instance of `SPiDAuthorizationRequest`
*/
- (id)initWithCompletionHandler:(void (^)(SPiDAccessToken *accessToken, NSError *error))completionHandler;

/** Tries to authorize with SPiD

 This causes a redirect to Safari that will redirect back to the app by calling `application:openURL:sourceApplication:annotation:`
*/
- (void)authorize;

/** Tries to refresh the access token

 Requests are queued during refresh and run again after refresh is completed

 @param accessToken Access token to refresh
*/
- (void)refreshWithRefreshToken:(SPiDAccessToken *)accessToken;

/** Tries to logout from SPiD

 This causes a redirect to Safari that will redirect back to the app by calling `application:openURL:sourceApplication:annotation:`
 This will remove the cookie from Safari and force user to login again
 
 @param accessToken `SPiDAccessToken` to be logged out
*/
- (void)logoutWithAccessToken:(SPiDAccessToken *)accessToken;

/** Tries to soft logout from SPiD

 This will not redirect to Safari and the cookie will not be removed.
 This method is used when a user tries to login twice, the logout invalidates the old token making sure that there is only one active token.

 @param accessToken `SPiDAccessToken` to be logged out
*/
- (void)softLogoutWithAccessToken:(SPiDAccessToken *)accessToken;

/** Handles the redirects from Safari

 Called from `SPiDClient` and should not be called directly

 @param url The URL received from Safari
 @return YES if URL was handled otherwise NO
*/
- (BOOL)handleOpenURL:(NSURL *)url;

@end
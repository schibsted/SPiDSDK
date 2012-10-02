//
//  SPiDAuthorizationRequest.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/21/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDConstants.h"
#import "SPiDClient.h"
#import "SPiDAccessToken.h"

/**
 Class description....
 */

@interface SPiDAuthorizationRequest : NSObject <NSURLConnectionDelegate>

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** Creates a `SPiDAuthorizationRequest` and and setups completionHandler

*/
- (id)initWithCompletionHandler:(void (^)(SPiDAccessToken *accessToken, NSError *error))handler;

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
*/
- (void)logoutWithAccessToken:(SPiDAccessToken *)accessToken;

/** Tries to soft logout from SPiD

 This will not redirect to Safari and the cookie will not be removed
*/
- (void)softLogoutWithAccessToken:(SPiDAccessToken *)accessToken;

/** Handles the redirects back from Safari

 @param url The URL received from Safari
 @return YES if URL was handled otherwise NO
*/
- (BOOL)handleOpenURL:(NSURL *)url;

/**

*/
@end
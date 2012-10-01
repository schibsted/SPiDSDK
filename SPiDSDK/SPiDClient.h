//
//  SPiDClient.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDConstants.h"
#import "SPiDUtils.h"

@class SPiDAuthorizationRequest;
@class SPiDResponse;

/**
 * Class description.....
 *
 **/

// TODO: Change this to SPID_DEBUG?
#ifdef DEBUG
#   define SPiDDebugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define SPiDDebugLog(...)
#endif

@interface SPiDClient : NSObject

@property(strong, nonatomic) NSString *clientID;
@property(strong, nonatomic) NSString *clientSecret;
@property(strong, nonatomic) NSString *appURLScheme;
@property(strong, nonatomic) NSURL *redirectURI; // TODO: Default to appURLScheme://SPiD/{login|logout|failure}
@property(strong, nonatomic) NSURL *spidURL;
@property(strong, nonatomic) NSURL *authorizationURL;
@property(strong, nonatomic) NSURL *tokenURL;
@property(nonatomic) BOOL saveToKeychain;

/** Returns the singleton instance of SPiDClient

 @return Returns singleton instance
 */

+ (SPiDClient *)sharedInstance;

/** Configures the `SPiDClient`

 @param clientID The client ID provided by SPiD
 @param clientSecret The client secret provided by SPiD
 @param appURLSchema The url schema for the app (eg spidtest://)
 @param spidURL The url to SPiD
 */
- (void)setClientID:(NSString *)clientID
    andClientSecret:(NSString *)clientSecret
    andAppURLScheme:(NSString *)appURLSchema
         andSPiDURL:(NSURL *)spidURL;

/** Handles URL redirects to the app

 @param url Input URL
 @return Returns YES if URL was handled by `SPiDClient`
 */
- (BOOL)handleOpenURL:(NSURL *)url;

/** Authorizes with SPiD

 This requires that the `SPiDClient` has been configured.
 Redirects to safari to get code and then uses this to obtain a access token.
 The access token is then saved to keychain

 @warning `SPiDClient` has to be configured before calling `authorizationRequestWithCompletionHandler`
 @param completionHandler Run after authorization is completed
 */
- (void)authorizationRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler;

/** Logout from SPiD

 This requires that the app has obtained a access token.
 Redirects to safari to logout from SPiD and remove cookie.
 Also removes access token from keychain

 @warning `SPiDClient` has to be logged in before this call
 @param completionHandler Run after logout is completed
 @see authorizationRequestWithCompletionHandler:
 @see isLoggedIn
 */
- (void)logoutRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler;

/** Refresh access token

 Forces refresh of access token, this is unusally not needed since SPiDSDK will automatically refresh token when needed.
 The access token is then saved to keychain

 @warning `SPiDClient` has to be logged in before this call
 @param completionHandler Run after authorization is completed
 @see authorizationRequestWithCompletionHandler:
 @see isLoggedIn
 */
- (void)refreshAccessTokenRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler;

/** Requests the currently logged in user’s object.

 For information about the return object see: <http://www.schibstedpayment.no/docs/doku.php?id=wiki:user_api>

 @warning Requires that the user is authorized with SPiD
 @param completionHandler Run after request is completed
 @see authorizationRequestWithCompletionHandler:
 @see isLoggedIn
 */
- (void)meRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Request all login attempts for a specific client

 For information about the return object see: <http://www.schibstedpayment.no/docs/doku.php?id=wiki:login_api>

 @warning Requires that the user is authorized with SPiD
 @param userID The userID that logins should be fetched for
 @param completionHandler Run after request is completed
 @see authorizationRequestWithCompletionHandler:
 @see isLoggedIn
 */
- (void)loginsRequestWithUserID:(NSString *)userID andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Checks if the access token has expired

 @return Returns YES if access token has expired
 */
- (BOOL)hasTokenExpired;

/** Returns the time when access token expires

 @return Returns the date when the access token expires
 */
- (NSDate *)tokenExpiresAt;

/** Returns YES if `SPiDClient` has a access token and is logged in

 @return Returns YES if `SPiDClient` is logged in
 */
- (BOOL)isLoggedIn;

@end

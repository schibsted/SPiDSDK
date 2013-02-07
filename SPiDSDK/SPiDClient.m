//
//  SPiDClient.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDClient.h"
#import "SPiDAuthorizationRequest.h"
#import "SPiDRequest.h"
#import "SPiDKeychainWrapper.h"
#import "SPiDResponse.h"

@interface SPiDClient (PrivateMethods)

/** Initializes the `SPiDClient` should not be called directly

 Tries to load the access token from the keychain
 */
- (id)init;

/** Runs after authorization has been completed, should not be called directly
*
 @param token Access token returned from SPiD
 */
- (void)authorizationComplete:(SPiDAccessToken *)token;

/** Creates and runs the authorization request

 This requires that the `SPiDClient` has been configured.
 Redirects to safari to get code and then uses this to obtain a access token.
 The access token is then saved to keychain

 @warning This should not be called directly, all validation is placed in ´authorizationRequestWithCompletionHandler:` an should be called instead. Using this method directly causes multiple active tokens on the server.
 @param _completionHandler Run after authorization is completed
 @see authorizationRequestWithCompletionHandler:
 */
- (void)doBrowserRedirectAuthorizationRequestWithCompletionHandler:(void (^)(NSError *))completionHandler;

/** Runs after logout has been completed, should not be called directly */
- (void)logoutComplete;

@end

@implementation SPiDClient {
@private
    NSMutableArray *waitingRequests;
    NSInteger tokenRefreshRetryCount;
    SPiDAuthorizationRequest *authorizationRequest;
    SPiDAccessToken *accessToken;
    NSString *_webViewInitialHTML;
}

@synthesize clientID = _clientID;
@synthesize serverClientID = _serverClientID;
@synthesize clientSecret = _clientSecret;
@synthesize sigSecret = _sigSecret;
@synthesize appURLScheme = _appURLScheme;
@synthesize redirectURI = _redirectURI;
@synthesize serverURL = _serverURL;
@synthesize authorizationURL = _authorizationURL;
@synthesize registrationURL = _registrationURL;
@synthesize lostPasswordURL = _lostPasswordURL;
@synthesize tokenURL = _tokenURL;
@synthesize apiVersionSPiD = _apiVersionSPiD;
@synthesize useMobileWeb = _useMobileWeb;
@synthesize webViewInitialHTML = _webViewInitialHTML;


#pragma mark Public methods

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

+ (SPiDClient *)sharedInstance {
    static SPiDClient *sharedSPiDClientInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedSPiDClientInstance = [[self alloc] init];
    });

    return sharedSPiDClientInstance;
}

- (void)setClientID:(NSString *)clientID
       clientSecret:(NSString *)clientSecret
       appURLScheme:(NSString *)appURLSchema
          serverURL:(NSURL *)serverURL {
    [self setClientID:clientID];
    [self setClientSecret:clientSecret];
    [self setServerURL:serverURL];

    NSString *escapedAppURL = [appURLSchema stringByReplacingOccurrencesOfString:@":" withString:@""];
    escapedAppURL = [escapedAppURL stringByReplacingOccurrencesOfString:@"/" withString:@""];
    [self setAppURLScheme:escapedAppURL];

    // Generates URL default urls
    if (![self redirectURI])
        [self setRedirectURI:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", [self appURLScheme]]]];

    if (![self authorizationURL])
        [self setAuthorizationURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/login", [self serverURL]]]];

    if (![self registrationURL])
        [self setRegistrationURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/signup", [self serverURL]]]];

    if (![self lostPasswordURL])
        [self setLostPasswordURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/forgotpassword", [self serverURL]]]];

    if (![self tokenURL])
        [self setTokenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/token", [self serverURL]]]];

    if (![self serverClientID])
        [self setServerClientID:clientID];

    if (![self webViewInitialHTML])
        [self setWebViewInitialHTML:@""];
}

- (void)browserRedirectAuthorizationWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    // Sanity check
    NSAssert([self authorizationURL], @"SPiDOAuth2 missing authorization URL.");
    NSAssert([self clientID], @"SPiDOAuth2 missing client ID.");
    NSAssert([self clientSecret], @"SPiDOAuth2 missing client secret.");
    NSAssert([self redirectURI], @"SPiDOAuth2 missing redirect url.");

    // If we are logged in do a soft logout before continuing
    if (accessToken) {
        SPiDDebugLog(@"Access token found, preforming a soft logout to cleanup before login");
        [self softLogoutRequestWithCompletionHandler:^(NSError *error) {
            if (error) {
                [self clearAuthorizationRequest];
                completionHandler(error);
            } else {
                [self doBrowserRedirectAuthorizationRequestWithCompletionHandler:completionHandler];
            }
        }];
    } else { // No access token
        [self doBrowserRedirectAuthorizationRequestWithCompletionHandler:completionHandler];
    }
}

- (UIWebView *)webViewAuthorizationWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    SPiDAuthorizationRequest *request = [self createWebViewAuthRequestWithCompletionHandler:completionHandler];
    return [request authorizeWithWebView];
}

- (UIWebView *)webViewRegistrationWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    SPiDAuthorizationRequest *request = [self createWebViewAuthRequestWithCompletionHandler:completionHandler];
    return [request registerWithWebView];
}

- (UIWebView *)webViewLostPasswordWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    SPiDAuthorizationRequest *request = [self createWebViewAuthRequestWithCompletionHandler:completionHandler];
    return [request lostPasswordWithWebView];
}

- (SPiDAuthorizationRequest *)createWebViewAuthRequestWithCompletionHandler:(void (^)(NSError *))completionHandler {
    // Sanity check
    NSAssert([self authorizationURL], @"SPiDOAuth2 missing authorization URL.");
    NSAssert([self clientID], @"SPiDOAuth2 missing client ID.");
    NSAssert([self clientSecret], @"SPiDOAuth2 missing client secret.");
    NSAssert([self redirectURI], @"SPiDOAuth2 missing redirect url.");
    //NSAssert(!authorizationRequest, @"Authorization request already running");
    // TODO: Should we validate that url starts with https?

    // We are already logged in, do nothing
    if (accessToken) {
        SPiDDebugLog(@"Access token found, preforming a soft logout to cleanup before login");
        // Fire and forget
        SPiDAuthorizationRequest *authRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
        }];
        [authRequest softLogoutWithAccessToken:accessToken];
        // Clear token
        accessToken = nil;
        [SPiDKeychainWrapper removeAccessTokenFromKeychainForIdentifier:AccessTokenKeychainIdentification];
    }
    @synchronized (authorizationRequest) {
        authorizationRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
            if (error) {
                [self clearAuthorizationRequest];
                completionHandler(error);
            } else {
                [self authorizationComplete:token];
                completionHandler(nil);
            }
        }];
    }
    return authorizationRequest;
}

- (BOOL)handleOpenURL:(NSURL *)url {
    SPiDDebugLog(@"SPiDSDK received url: %@", [url absoluteString]);
    NSString *redirectURLString = [[self redirectURI] absoluteString];
    NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
    if ([urlString hasPrefix:redirectURLString] && authorizationRequest) {
        if ([urlString hasSuffix:@"login"]) {
            // Assert
            return [authorizationRequest handleOpenURL:url];
        } else if ([urlString hasSuffix:@"logout"]) {
            return [authorizationRequest handleOpenURL:url];
        } else if ([urlString hasSuffix:@"failure"]) {
            return [authorizationRequest handleOpenURL:url];
        }
    }
    return NO;
}

- (void)logoutRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    @synchronized (authorizationRequest) {
        if (!authorizationRequest) {
            authorizationRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
                if (!error) {
                    [self logoutComplete];
                } else {
                    [self clearAuthorizationRequest];
                }
                completionHandler(error);
            }];
            [authorizationRequest logoutWithAccessToken:accessToken];
        }
    }
}

- (void)softLogoutRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    @synchronized (authorizationRequest) {
        if (!authorizationRequest) {
            authorizationRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
                if (!error) {
                    [self logoutComplete];
                } else {
                    [self clearAuthorizationRequest];
                }
                completionHandler(error);
            }];
            [authorizationRequest softLogoutWithAccessToken:accessToken];
        }
    }
}

- (void)refreshAccessTokenRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    @synchronized (authorizationRequest) {
        if (!authorizationRequest) {
            authorizationRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
                if (!error) {
                    [self authorizationComplete:token];
                } else {
                    [self clearAuthorizationRequest];
                }
                completionHandler(error);
            }];
            [authorizationRequest refreshWithRefreshToken:accessToken];
        } else {
            SPiDDebugLog(@"Token refresh already running");
        }
    }
}

- (void)refreshAccessTokenAndRerunRequest:(SPiDRequest *)request {
    if (!waitingRequests) {
        waitingRequests = [[NSMutableArray alloc] init];
    }
    [waitingRequests addObject:request];

    [self refreshAccessTokenRequestWithCompletionHandler:^(NSError *error) {
    }];
}

- (void)apiGetRequestWithPath:(NSString *)path completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    //NSAssert(accessToken, @"SPiDOAuth2 missing access token, authorization needed before api request.");
    SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:completionHandler];
    if ([accessToken hasExpired] || authorizationRequest) {
        SPiDDebugLog(@"Access token has expired at %@, trying to get a new one", [accessToken expiresAt]);
        if (!waitingRequests) {
            waitingRequests = [[NSMutableArray alloc] init];
        }
        [waitingRequests addObject:request];

        [self refreshAccessTokenRequestWithCompletionHandler:^(NSError *error) {
        }];
    } else {
        [request startRequestWithAccessToken:accessToken];
    }
}

- (void)apiPostRequestWithPath:(NSString *)path body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *))completionHandler {
    //NSAssert(accessToken, @"SPiDOAuth2 missing access token, authorization needed before api request.");
    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:path body:body completionHandler:completionHandler];
    if ([accessToken hasExpired] || authorizationRequest) {
        SPiDDebugLog(@"Access token has expired at %@, trying to get a new one", [accessToken expiresAt]);
        if (!waitingRequests) {
            waitingRequests = [[NSMutableArray alloc] init];
        }
        [waitingRequests addObject:request];

        [self refreshAccessTokenRequestWithCompletionHandler:^(NSError *error) {
        }];
    } else {
        [request startRequestWithAccessToken:accessToken];
    }
}

- (void)clearAuthorizationRequest {
    @synchronized (authorizationRequest) {
        authorizationRequest = nil;
    }
    waitingRequests = nil;
}

- (NSString *)currentUserID {
    if (accessToken)
        return accessToken.userID;
    return nil;
}

- (BOOL)isAuthorized {
    if (accessToken)
        return YES;
    return NO;
}

- (BOOL)hasTokenExpired {
    if (accessToken) {
        return accessToken.hasExpired;
    }
    return NO;
}

- (NSDate *)tokenExpiresAt {
    if (accessToken) {
        return accessToken.expiresAt;
    }
    return [NSDate date];
}

#pragma mark Request wrappers

///---------------------------------------------------------------------------------------
/// @name Request wrappers
///---------------------------------------------------------------------------------------

- (void)getOneTimeCodeRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/oauth/exchange"];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];

    // TODO: This should be client_id!
    [data setObject:[self serverClientID] forKey:@"clientId"];
    [data setObject:[self serverClientID] forKey:@"client_id"];
    [data setObject:@"code" forKey:@"type"];
    [self apiPostRequestWithPath:path body:data completionHandler:completionHandler];
}

- (void)getMeRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/me"];
    [self apiGetRequestWithPath:path completionHandler:completionHandler];
}

- (void)getUserRequestWithID:(NSString *)userID completionHandler:(void (^)(SPiDResponse *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/user/%@", userID];
    [self apiGetRequestWithPath:path completionHandler:completionHandler];
}

- (void)getCurrentUserRequestWithCompletionHandler:(void (^)(SPiDResponse *))completionHandler {
    [self getUserRequestWithID:accessToken.userID completionHandler:completionHandler];
}

- (void)getUserLoginsRequestWithUserID:(NSString *)userID completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/user/%@/logins", userID];
    [self apiGetRequestWithPath:path completionHandler:completionHandler];
}


#pragma mark Private methods

///---------------------------------------------------------------------------------------
/// @name Private methods
///---------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self) {
        accessToken = [SPiDKeychainWrapper getAccessTokenFromKeychainForIdentifier:AccessTokenKeychainIdentification];
        if (![self apiVersionSPiD]) {
            [self setApiVersionSPiD:[NSString stringWithFormat:@"%@", defaultAPIVersionSPiD]];
        }
        [self setUseMobileWeb:YES];
    }
    return self;
}


- (void)doBrowserRedirectAuthorizationRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    @synchronized (authorizationRequest) {
        authorizationRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
            if (error) {
                [self clearAuthorizationRequest];
                completionHandler(error);
            } else {
                [self authorizationComplete:token];
                completionHandler(nil);
            }
        }];
    }
    [authorizationRequest authorizeWithBrowserRedirect];
}

- (void)authorizationComplete:(SPiDAccessToken *)token {
    accessToken = token;
    SPiDDebugLog(@"Received access token: %@ expires at: %@ refresh token: %@", [accessToken accessToken], [accessToken expiresAt], [accessToken refreshToken]);

    [SPiDKeychainWrapper storeInKeychainAccessTokenWithValue:token forIdentifier:AccessTokenKeychainIdentification];

    if (waitingRequests) {
        SPiDDebugLog(@"Found %d waiting request, running again", [waitingRequests count]);
        for (SPiDRequest *request in waitingRequests) {
            [request startRequestWithAccessToken:accessToken];
        }
        waitingRequests = nil;
    }
    [self clearAuthorizationRequest];
}

- (void)logoutComplete {
    SPiDDebugLog(@"Logged out from SPiD");
    accessToken = nil;

    [SPiDKeychainWrapper removeAccessTokenFromKeychainForIdentifier:AccessTokenKeychainIdentification];

    [self clearAuthorizationRequest];

    waitingRequests = nil;
}

- (SPiDAccessToken *)getAccessToken {
    return accessToken;
}

- (void)setAccessToken:(SPiDAccessToken *)token {
    accessToken = token;

}
@end

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

static NSString *const AccessTokenKeychainIdentification = @"AccessToken";

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
 @param completionHandler Run after authorization is completed
 @see authorizationRequestWithCompletionHandler:
 */
- (void)doBrowserRedirectAuthorizationRequestWithCompletionHandler:(void (^)(NSError *))completionHandler;

/** Runs after logout has been completed, should not be called directly */
- (void)logoutComplete;

@end

@implementation SPiDClient {
@private
    NSMutableArray *waitingRequests;
    NSInteger tokenRefreshRetryCount; // TODO: implement retries
    SPiDAuthorizationRequest *authorizationRequest;
    SPiDAccessToken *accessToken;
    NSString *_webViewInitialHTML;
}

@synthesize clientID = _clientID;
@synthesize clientSecret = _clientSecret;
@synthesize appURLScheme = _appURLScheme;
@synthesize redirectURI = _redirectURI;
@synthesize serverURL = _serverURL;
@synthesize authorizationURL = _authorizationURL;
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
    andClientSecret:(NSString *)clientSecret
    andAppURLScheme:(NSString *)appURLSchema
       andServerURL:(NSURL *)serverURL {
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

    if (![self tokenURL])
        [self setTokenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/token", [self serverURL]]]];

    if (![self webViewInitialHTML])
        [self setWebViewInitialHTML:@""];
}

- (void)browserRedirectAuthorizationWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    // Sanity check
    NSAssert([self authorizationURL], @"SPiDOAuth2 missing authorization URL.");
    NSAssert([self clientID], @"SPiDOAuth2 missing client ID.");
    NSAssert([self clientSecret], @"SPiDOAuth2 missing client secret.");
    NSAssert([self redirectURI], @"SPiDOAuth2 missing redirect url.");
    // TODO: Should this happen?
    // NSAssert(!authorizationRequest, @"Authorization request already running");
    // TODO: Should we validate that url starts with https?

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
    }
    return [self doWebViewAuthorizationRequestWithCompletionHandler:completionHandler];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    SPiDDebugLog(@"SPiDSDK received url: %@", [url absoluteString]);
    NSString *redirectURLString = [[self redirectURI] absoluteString];
    NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
    if ([urlString hasPrefix:redirectURLString]) {
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

- (void)apiGetRequestWithPath:(NSString *)path andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSAssert(accessToken, @"SPiDOAuth2 missing access token, authorization needed before api request.");
    NSString *apiPath = [NSString stringWithFormat:@"/api/%@%@", [self apiVersionSPiD], path];
    SPiDRequest *request = [[SPiDRequest alloc] initGetRequestWithPath:apiPath andCompletionHandler:completionHandler];
    if ([accessToken hasTokenExpired] || authorizationRequest) {
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

- (void)apiPostRequestWithPath:(NSString *)path andBody:(NSDictionary *)body andCompletionHandler:(void (^)(SPiDResponse *))completionHandler {
    NSAssert(accessToken, @"SPiDOAuth2 missing access token, authorization needed before api request.");
    NSString *apiPath = [NSString stringWithFormat:@"/api/%@%@", [self apiVersionSPiD], path];
    SPiDRequest *request = [[SPiDRequest alloc] initPostRequestWithPath:apiPath andHTTPBody:body andCompletionHandler:completionHandler];
    if ([accessToken hasTokenExpired] || authorizationRequest) {
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
        return accessToken.hasTokenExpired;
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
    [data setObject:@"4fe9cb8adcb114f64a000001" forKey:@"clientId"];
    [data setObject:@"4fe9cb8adcb114f64a000001" forKey:@"client_id"];
    [data setObject:@"code" forKey:@"type"];
    [self apiPostRequestWithPath:path andBody:data andCompletionHandler:completionHandler];
}

- (void)getMeRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/me"];
    [self apiGetRequestWithPath:path andCompletionHandler:completionHandler];
}

- (void)getUserRequestWithID:(NSString *)userID andCompletionHandler:(void (^)(SPiDResponse *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/user/%@", userID];
    [self apiGetRequestWithPath:path andCompletionHandler:completionHandler];
}

- (void)getUserRequestWithCurrentUserAndCompletionHandler:(void (^)(SPiDResponse *))completionHandler {
    [self getUserRequestWithID:accessToken.userID andCompletionHandler:completionHandler];
}

- (void)getUserLoginsRequestWithUserID:(NSString *)userID andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/user/%@/logins", userID];
    [self apiGetRequestWithPath:path andCompletionHandler:completionHandler];
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
    }
    return self;
}


- (void)doBrowserRedirectAuthorizationRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    @synchronized (authorizationRequest) {
        authorizationRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
            if (error) {
                [self clearAuthorizationRequest];
                authorizationRequest = nil;
                completionHandler(error);
            } else {
                [self authorizationComplete:token];
                completionHandler(nil);
            }
        }];
    }
    [authorizationRequest authorizeWithBrowserRedirect];
}

- (UIWebView *)doWebViewAuthorizationRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    @synchronized (authorizationRequest) {
        authorizationRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
            if (error) {
                [self clearAuthorizationRequest];
                authorizationRequest = nil;
                completionHandler(error);
            } else {
                [self authorizationComplete:token];
                completionHandler(nil);
            }
        }];
    }
    return [authorizationRequest authorizeWithWebView];
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

@end

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
#import "SPiDWebView.h"

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
    NSMutableArray *_waitingRequests;
    NSInteger tokenRefreshRetryCount;
    BOOL _isAuthorizing;
    SPiDAuthorizationRequest *authorizationRequest;
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
@synthesize signupURL = _signupURL;
@synthesize forgotPasswordURL = _forgotPasswordURL;
@synthesize tokenURL = _tokenURL;
@synthesize apiVersionSPiD = _apiVersionSPiD;
@synthesize useMobileWeb = _useMobileWeb;
@synthesize webViewInitialHTML = _webViewInitialHTML;
@synthesize accessToken = _accessToken;
@synthesize waitingRequests = _waitingRequests;


#pragma mark Public methods

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------
static SPiDClient *sharedSPiDClientInstance = nil;

+ (SPiDClient *)sharedInstance {
    if (sharedSPiDClientInstance == nil) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"[%@ %@] cannot be called before SPiDClient has been configured; use +[%@ %@]",
                           NSStringFromClass([self class]),
                           NSStringFromSelector(_cmd),
                           NSStringFromClass([self class]),
                           NSStringFromSelector(@selector(setClientID:clientSecret:appURLScheme:serverURL:))];
    } else {
        return sharedSPiDClientInstance;
    }
}

+ (void)setClientID:(NSString *)clientID
       clientSecret:(NSString *)clientSecret
       appURLScheme:(NSString *)appURLSchema
          serverURL:(NSURL *)serverURL {

    if (sharedSPiDClientInstance != nil) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"[%@ %@] cannot be called more than once",
                           NSStringFromClass([self class]),
                           NSStringFromSelector(_cmd)];
    }
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedSPiDClientInstance = [[self alloc] init];
    });

    [sharedSPiDClientInstance setClientID:clientID];
    [sharedSPiDClientInstance setClientSecret:clientSecret];
    [sharedSPiDClientInstance setServerURL:serverURL];

    NSString *escapedAppURL = [appURLSchema stringByReplacingOccurrencesOfString:@":" withString:@""];
    escapedAppURL = [escapedAppURL stringByReplacingOccurrencesOfString:@"/" withString:@""];
    [sharedSPiDClientInstance setAppURLScheme:escapedAppURL];

    // Generates URL default urls
    if (![sharedSPiDClientInstance redirectURI])
        [sharedSPiDClientInstance setRedirectURI:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", [sharedSPiDClientInstance appURLScheme]]]];

    if (![sharedSPiDClientInstance authorizationURL])
        [sharedSPiDClientInstance setAuthorizationURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/login", [sharedSPiDClientInstance serverURL]]]];

    if (![sharedSPiDClientInstance signupURL])
        [sharedSPiDClientInstance setSignupURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/signup", [sharedSPiDClientInstance serverURL]]]];

    if (![sharedSPiDClientInstance forgotPasswordURL])
        [sharedSPiDClientInstance setForgotPasswordURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/forgotpassword", [sharedSPiDClientInstance serverURL]]]];

    if (![sharedSPiDClientInstance tokenURL])
        [sharedSPiDClientInstance setTokenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/token", [sharedSPiDClientInstance serverURL]]]];

    if (![sharedSPiDClientInstance serverClientID])
        [sharedSPiDClientInstance setServerClientID:clientID];

    if (![sharedSPiDClientInstance webViewInitialHTML])
        [sharedSPiDClientInstance setWebViewInitialHTML:@""];
}

- (void)browserRedirectAuthorizationWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    // Sanity check
    NSAssert([self authorizationURL], @"SPiDOAuth2 missing authorization URL.");
    NSAssert([self clientID], @"SPiDOAuth2 missing client ID.");
    NSAssert([self clientSecret], @"SPiDOAuth2 missing client secret.");
    NSAssert([self redirectURI], @"SPiDOAuth2 missing redirect url.");

    // If we are logged in do a soft logout before continuing
    if (self.accessToken) {
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

- (UIWebView *)webViewAuthorizationWithCompletionHandler:(void (^)(NSString *code, NSError *response))completionHandler {
    SPiDWebView *webView = [SPiDWebView authorizationWebViewWithCompletionHandler:completionHandler];
    return webView;
}

- (UIWebView *)webViewSignupWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    SPiDWebView *webView = [SPiDWebView signupWebViewWithCompletionHandler:nil];
    return webView;
}

- (UIWebView *)webViewLostPasswordWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    SPiDWebView *webView = [SPiDWebView forgotPasswordWebViewWithCompletionHandler:nil];
    return webView;
}

- (NSString *)getAuthorizationQueryWithURL:(NSString *)requestURL {
    SPiDClient *client = [SPiDClient sharedInstance];
    requestURL = [requestURL stringByAppendingFormat:@"?%@=%@", @"client_id", [client clientID]];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", @"response_type", @"code"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", @"redirect_uri", [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@spid/login", [[client redirectURI] absoluteString]]]];
    if ([[SPiDClient sharedInstance] useMobileWeb])
        requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", @"platform", @"mobile"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", @"force", @"1"];
    return requestURL;
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
    if (self.accessToken) {
        SPiDDebugLog(@"Access token found, preforming a soft logout to cleanup before login");
        // Fire and forget
        SPiDAuthorizationRequest *authRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
        }];
        [authRequest softLogoutWithAccessToken:self.accessToken];
        // Clear token
        self.accessToken = nil;
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
            [authorizationRequest logoutWithAccessToken:self.accessToken];
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
            [authorizationRequest softLogoutWithAccessToken:self.accessToken];
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
            [authorizationRequest refreshWithRefreshToken:self.accessToken];
        } else {
            SPiDDebugLog(@"Token refresh already running");
        }
    }
}

- (void)refreshAccessTokenAndRerunRequest:(SPiDRequest *)request {
    if (!_waitingRequests) {
        _waitingRequests = [[NSMutableArray alloc] init];
    }
    [_waitingRequests addObject:request];

    [self refreshAccessTokenRequestWithCompletionHandler:^(NSError *error) {
    }];
}

- (void)apiGetRequestWithPath:(NSString *)path completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    //NSAssert(accessToken, @"SPiDOAuth2 missing access token, authorization needed before api request.");
    SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:completionHandler];
    if ([self.accessToken hasExpired] || authorizationRequest) {
        SPiDDebugLog(@"Access token has expired at %@, trying to get a new one", [self.accessToken expiresAt]);
        if (!_waitingRequests) {
            _waitingRequests = [[NSMutableArray alloc] init];
        }
        [_waitingRequests addObject:request];

        [self refreshAccessTokenRequestWithCompletionHandler:^(NSError *error) {
        }];
    } else {
        [request startRequestWithAccessToken:self.accessToken];
    }
}

- (void)apiPostRequestWithPath:(NSString *)path body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *))completionHandler {
    //NSAssert(accessToken, @"SPiDOAuth2 missing access token, authorization needed before api request.");
    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:path body:body completionHandler:completionHandler];
    if ([self.accessToken hasExpired] || authorizationRequest) {
        SPiDDebugLog(@"Access token has expired at %@, trying to get a new one", [self.accessToken expiresAt]);
        if (!_waitingRequests) {
            _waitingRequests = [[NSMutableArray alloc] init];
        }
        [_waitingRequests addObject:request];

        [self refreshAccessTokenRequestWithCompletionHandler:^(NSError *error) {
        }];
    } else {
        [request startRequestWithAccessToken:self.accessToken];
    }
}

- (void)clearAuthorizationRequest {
    @synchronized (authorizationRequest) {
        authorizationRequest = nil;
    }
    _waitingRequests = nil;
}

- (NSString *)authorizationURLWithQuery {
    NSString *query = [self getAuthorizationQuery];
    return [self.authorizationURL.absoluteString stringByAppendingString:query];
}

- (NSString *)signupURLWithQuery {
    NSString *query = [self getAuthorizationQuery];
    return [self.signupURL.absoluteString stringByAppendingString:query];
}

- (NSString *)forgotPasswordURLWithQuery {
    NSString *query = [self getAuthorizationQuery];
    return [self.forgotPasswordURL.absoluteString stringByAppendingString:query];
}

- (NSString *)getAuthorizationQuery {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setObject:self.clientID forKey:@"client_id"];
    [query setObject:@"code" forKey:@"response_type"];
    [query setObject:self.redirectURI.absoluteString forKey:@"redirect_uri"];
    if (self.useMobileWeb)
        [query setObject:@"mobile" forKey:@"platform"];
    [query setObject:@"1" forKey:@"force"];
    return [SPiDUtils encodedHttpQueryForDictionary:query];
}

- (NSString *)currentUserID {
    if (self.accessToken)
        return self.accessToken.userID;
    return nil;
}

- (BOOL)hasPendingAuthorization {
    return _isAuthorizing;
}

- (BOOL)isAuthorized {
    if (self.accessToken)
        return YES;
    return NO;
}

- (BOOL)isClientToken {
    if (self.accessToken)
        return self.accessToken.isClientToken;
    return NO;
}

- (BOOL)hasTokenExpired {
    if (self.accessToken) {
        return self.accessToken.hasExpired;
    }
    return NO;
}

- (NSDate *)tokenExpiresAt {
    if (self.accessToken) {
        return self.accessToken.expiresAt;
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
    [self getUserRequestWithID:self.accessToken.userID completionHandler:completionHandler];
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
        self.accessToken = [SPiDKeychainWrapper getAccessTokenFromKeychainForIdentifier:AccessTokenKeychainIdentification];
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
    self.accessToken = token;
    SPiDDebugLog(@"Received access token: %@ expires at: %@ refresh token: %@", self.accessToken.accessToken, self.accessToken.expiresAt, self.accessToken.refreshToken);

    [SPiDKeychainWrapper storeInKeychainAccessTokenWithValue:token forIdentifier:AccessTokenKeychainIdentification];

    if (_waitingRequests) {
        SPiDDebugLog(@"Found %d waiting request, running again", [_waitingRequests count]);
        for (SPiDRequest *request in _waitingRequests) {
            [request startRequestWithAccessToken:self.accessToken];
        }
        _waitingRequests = nil;
    }
    [self clearAuthorizationRequest];
}

- (void)logoutComplete {
    SPiDDebugLog(@"Logged out from SPiD");
    self.accessToken = nil;

    [SPiDKeychainWrapper removeAccessTokenFromKeychainForIdentifier:AccessTokenKeychainIdentification];

    [self clearAuthorizationRequest];

    _waitingRequests = nil;
}

@end

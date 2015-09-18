//
//  SPiDClient.m
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDClient.h"
#import "SPiDRequest.h"
#import "SPiDKeychainWrapper.h"
#import "SPiDResponse.h"
#import "SPiDError.h"
#import "SPiDTokenRequest.h"
#import "SPiDStatus.h"
#import "NSData+Base64.h"

@interface SPiDClient ()

/** Initializes the `SPiDClient` should not be called directly

 Tries to load the access token from the keychain
 */
- (id)init;

/** Runs after logout has been completed, should not be called directly */
- (void)logoutComplete;

/** Builds authorization query

 @return The authorization query parameters
 */
- (NSString *)getAuthorizationQuery;

/** Builds logout query

 @return The logout query parameters
 */
- (NSString *)getLogoutQuery;

/** Helper method

 @param url The url to handle
 */
- (BOOL)doHandleOpenURL:(NSURL *)url;

@end

@implementation SPiDClient {
@private
    NSMutableArray *_waitingRequests;
    NSInteger tokenRefreshRetryCount;
    BOOL _isAuthenticating; // prevent multiple token requests
    SPiDRequest *_authorizationRequest;
    NSString *_webViewInitialHTML;

    void (^_completionHandler)(SPiDError *error);

}

#pragma mark Public methods
static SPiDClient *sharedSPiDClientInstance = nil;

+ (SPiDClient *)sharedInstance {
    if (sharedSPiDClientInstance == nil) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"[%@ %@] cannot be called before SPiDClient has been configured; use +[%@ %@]",
                           NSStringFromClass([self class]),
                           NSStringFromSelector(_cmd),
                           NSStringFromClass([self class]),
                           NSStringFromSelector(@selector(setClientID:clientSecret:appURLScheme:serverURL:))];
    }

    return sharedSPiDClientInstance;
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
    
    NSString *redirectUri = nil;

    // Generates URL default urls
    if (![sharedSPiDClientInstance redirectURI]) {
        redirectUri = [NSString stringWithFormat:@"%@://spid", [sharedSPiDClientInstance appURLScheme]];
        [sharedSPiDClientInstance setRedirectURI:[NSURL URLWithString:redirectUri]];
    } else {
        redirectUri = [[sharedSPiDClientInstance redirectURI] absoluteString];
    }

    if (![sharedSPiDClientInstance authorizationURL])
        [sharedSPiDClientInstance setAuthorizationURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/flow/login", [sharedSPiDClientInstance serverURL]]]];

    if (![sharedSPiDClientInstance signupURL])
        [sharedSPiDClientInstance setSignupURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/flow/signup", [sharedSPiDClientInstance serverURL]]]];
    
    if (![sharedSPiDClientInstance accountSummaryURL])
        [sharedSPiDClientInstance setAccountSummaryURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/account/summary?client_id=%@", [sharedSPiDClientInstance serverURL], clientID]]];

    if (![sharedSPiDClientInstance forgotPasswordURL]) {
        NSString *forgotPasswordUrl = [NSString stringWithFormat:@"%@/flow/password?client_id=%@&redirect_uri=%@", [sharedSPiDClientInstance serverURL], clientID, [redirectUri stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        [sharedSPiDClientInstance setForgotPasswordURL:[NSURL URLWithString:forgotPasswordUrl]];
    }

    if (![sharedSPiDClientInstance tokenURL])
        [sharedSPiDClientInstance setTokenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/token", [sharedSPiDClientInstance serverURL]]]];

    if (![sharedSPiDClientInstance serverClientID])
        [sharedSPiDClientInstance setServerClientID:clientID];

    if (![sharedSPiDClientInstance serverRedirectUri])
        [sharedSPiDClientInstance setServerRedirectUri:[NSURL URLWithString:[NSString stringWithFormat:@"%@://spid", [sharedSPiDClientInstance appURLScheme]]]];

    if (![sharedSPiDClientInstance webViewInitialHTML])
        [sharedSPiDClientInstance setWebViewInitialHTML:@""];

    if (![sharedSPiDClientInstance logoutURL])
        [sharedSPiDClientInstance setLogoutURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/logout", [sharedSPiDClientInstance serverURL]]]];

    // Fire and forget
    [SPiDStatus runStatusRequest];
}

- (void)browserRedirectAuthorizationWithCompletionHandler:(void (^)(SPiDError *response))completionHandler {
    if (self.accessToken) { // we already have a access token
        SPiDDebugLog(@"Already logged in, aborting redirect");
        completionHandler(nil);
    } else {
        _completionHandler = completionHandler;
        NSURL *requestURL = [self authorizationURLWithQuery];
        SPiDDebugLog(@"Trying to authorize using browser redirect: %@", requestURL);
        [[UIApplication sharedApplication] openURL:requestURL];
    }
}

- (void)browserRedirectSignupWithCompletionHandler:(void (^)(SPiDError *response))completionHandler {
    _completionHandler = completionHandler;
    NSURL *requestURL = [self forgotPasswordURLWithQuery];
    SPiDDebugLog(@"Trying to authorize using browser redirect: %@", requestURL);
    [[UIApplication sharedApplication] openURL:requestURL];
}

- (void)browserRedirectForgotPasswordWithCompletionHandler:(void (^)(SPiDError *response))completionHandler {
    _completionHandler = completionHandler;
    [self browserRedirectForgotPassword];
}

- (void)browserRedirectForgotPassword {
    NSURL *requestURL = [self forgotPasswordURLWithQuery];
    SPiDDebugLog(@"Trying to authorize using browser redirect: %@", requestURL);
    [[UIApplication sharedApplication] openURL:requestURL];
}

- (void)browserRedirectAccountSummary {
    NSURL *requestURL = [self accountSummaryURL];

    SPiDDebugLog(@"Trying to open account summary: %@", requestURL);
    if([[UIApplication sharedApplication] canOpenURL:requestURL]) {
       [[UIApplication sharedApplication] openURL:requestURL];
    }
}

- (void)browserRedirectLogoutWithCompletionHandler:(void (^)(SPiDError *response))completionHandler {
    _completionHandler = completionHandler;
    NSURL *requestURL = [self logoutURLWithQuery];
    SPiDDebugLog(@"Trying to logout from SPiD");
    SPiDDebugLog(@"%@", requestURL.absoluteString);
    [[UIApplication sharedApplication] openURL:requestURL];
}

- (BOOL)handleOpenURL:(NSURL *)url completionHandler:(void (^)(SPiDError *response))completionHandler {
    _completionHandler = completionHandler;
    return [self handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    SPiDDebugLog(@"SPiDSDK received url: %@", [url absoluteString]);
    NSString *redirectURLString = [[self redirectURI] absoluteString];
    NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];

    if ([urlString hasPrefix:redirectURLString] && _completionHandler) {
        if ([urlString hasSuffix:@"login"]) {
            // Assert
            return [self doHandleOpenURL:url];
        } else if ([urlString hasSuffix:@"logout"]) {
            return [self doHandleOpenURL:url];
        } else if ([urlString hasSuffix:@"failure"]) {
            return [self doHandleOpenURL:url];
        }
    }

    return NO;
}

- (SPiDRequest *)logoutRequestWithCompletionHandler:(void (^)(SPiDError *error))completionHandler {
    @synchronized (_authorizationRequest) {
        if (_authorizationRequest == nil) { // can't logout if we are already logging in
            // TODO: We should implement a api endpoint for logout
            NSString *path = [@"/logout" stringByAppendingString:[self getLogoutQuery]];
            SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:^(SPiDResponse *response) {
                [self logoutComplete];
/*
                if (response.error) {
                    [self clearAuthorizationRequest];
                } else{
                    [self logoutComplete];
                }
*/
                completionHandler(response.error);
            }];
            return request;
        } else {
            completionHandler([SPiDError apiErrorWithCode:-123 reason:@"SPiD request already in progress" descriptions:nil]);
            // TODO completionHandler( already running);
        }
    }
    return nil;
}

- (NSURL *)authorizationURLWithQuery {
    NSString *query = [self getAuthorizationQuery];
    return [NSURL URLWithString:[self.authorizationURL.absoluteString stringByAppendingString:query]];
}

- (NSURL *)signupURLWithQuery {
    NSString *query = [self getAuthorizationQuery];
    return [NSURL URLWithString:[self.signupURL.absoluteString stringByAppendingString:query]];
}

- (NSURL *)forgotPasswordURLWithQuery {
    //NSString *query = [self getForgotPasswordQuery];
    NSString *query = [self getAuthorizationQuery];
    return [NSURL URLWithString:[self.forgotPasswordURL.absoluteString stringByAppendingString:query]];
}

- (NSURL *)logoutURLWithQuery {
    NSString *query = [self getLogoutQuery];
    return [NSURL URLWithString:[self.logoutURL.absoluteString stringByAppendingString:query]];
}

- (NSString *)currentUserID {
    if (self.accessToken)
        return self.accessToken.userID;
    return nil;
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
    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:path body:data completionHandler:completionHandler];
    [request startRequestWithAccessToken];
}

- (void)getSessionCodeRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/oauth/exchange"];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];

    [data setObject:[self serverClientID] forKey:@"clientId"];
    [data setObject:[[self serverRedirectUri] absoluteString] forKey:@"redirectUri"];
    [data setObject:@"session" forKey:@"type"];
    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:path body:data completionHandler:completionHandler];
    [request startRequestWithAccessToken];
}

- (void)getMeRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/me"];
    SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:completionHandler];
    [request startRequestWithAccessToken];
}

- (void)getUserRequestWithID:(NSString *)userID completionHandler:(void (^)(SPiDResponse *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/user/%@", userID];
    SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:completionHandler];
    [request startRequestWithAccessToken];
}

- (void)getCurrentUserRequestWithCompletionHandler:(void (^)(SPiDResponse *))completionHandler {
    [self getUserRequestWithID:self.accessToken.userID completionHandler:completionHandler];
}

- (void)getUserLoginsRequestWithUserID:(NSString *)userID completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/user/%@/logins", userID];
    SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:completionHandler];
    [request startRequestWithAccessToken];
}

- (void)getEmailStatusWithEmail:(NSString *)email completionHandler:(void (^)(SPiDResponse *responce)) completionHandler {
    NSData *data = [email dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedEmail = [data base64EncodedUrlSafeString];
    
    NSString *path = [NSString stringWithFormat:@"/email/%@/status", encodedEmail];
    SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:completionHandler];
    [request startRequestWithAccessToken];
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

- (BOOL)doHandleOpenURL:(NSURL *)url {
    NSString *error = [SPiDUtils getUrlParameter:url forKey:@"error"];
    if (error) {
        SPiDDebugLog(@"Received error from SPiD: %@", error)
        _completionHandler([SPiDError oauth2ErrorWithString:error]);
        return NO;
    } else {
        NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
        if ([urlString hasSuffix:@"login"]) {
            NSString *code = [SPiDUtils getUrlParameter:url forKey:@"code"];

            if (code) {
                //NSAssert(code, @"SPiDOAuth2 missing code, this should not happen.");
                SPiDDebugLog(@"Received code: %@", code);
                SPiDTokenRequest *request = [SPiDTokenRequest userTokenRequestWithCode:code completionHandler:_completionHandler];
                [request startRequest];
            } else {
                // Logout
                _completionHandler([SPiDError oauth2ErrorWithCode:SPiDUserAbortedLogin reason:@"UserAbortedLogin" descriptions:[NSDictionary dictionaryWithObjectsAndKeys:@"User aborted login", @"error", nil]]);
            }
        } else if ([urlString hasSuffix:@"logout"]) {
            SPiDDebugLog(@"Logged out from SPiD");
            [self logoutComplete];
            _completionHandler(nil);
        }
        return YES;
    }
}

- (NSString *)getAuthorizationQuery {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setObject:self.clientID forKey:@"client_id"];
    if ([self.redirectURI.absoluteString hasSuffix:@"/"]) {
        [query setObject:[self.redirectURI.absoluteString stringByAppendingString:@"login"] forKey:@"redirect_uri"];
    } else {
        [query setObject:[self.redirectURI.absoluteString stringByAppendingString:@"/login"] forKey:@"redirect_uri"];
    }
    [query setObject:@"authorization_code" forKey:@"grant_type"];
    [query setObject:@"code" forKey:@"response_type"];
    if (self.useMobileWeb)
        [query setObject:@"mobile" forKey:@"platform"];
    // TODO: needed for browser redirect
    [query setObject:@"1" forKey:@"force"];
    return [SPiDUtils encodedHttpQueryForDictionary:query];
}

- (NSString *)getLogoutQuery {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setObject:self.clientID forKey:@"client_id"];
    if ([self.redirectURI.absoluteString hasSuffix:@"/"]) {
        [query setObject:[self.redirectURI.absoluteString stringByAppendingString:@"logout"] forKey:@"redirect_uri"]; // add spid/logout
    } else {
        [query setObject:[self.redirectURI.absoluteString stringByAppendingString:@"/logout"] forKey:@"redirect_uri"]; // add spid/logout
    }
    if (self.useMobileWeb)
        [query setObject:@"mobile" forKey:@"platform"];
    [query setObject:@"1" forKey:@"force"];
    return [SPiDUtils encodedHttpQueryForDictionary:query];
}

- (void)refreshAccessTokenAndRerunRequest:(SPiDRequest *)request {
    if (!_waitingRequests) {
        _waitingRequests = [[NSMutableArray alloc] init];
    }
    [_waitingRequests addObject:request];

    @synchronized (_authorizationRequest) {
        if (_authorizationRequest == nil) { // can't logout if we are already logging in
            _authorizationRequest = [SPiDTokenRequest refreshTokenRequestWithCompletionHandler:^(SPiDError *error) {
                [self authorizationComplete];
            }];
            [_authorizationRequest startRequest];
        }
    }
}

- (void)clearAuthorizationRequest {
    @synchronized (_authorizationRequest) {
        _authorizationRequest = nil;
    }
    self.waitingRequests = nil;
}

- (void)authorizationComplete {
    SPiDDebugLog(@"Received access token: %@ expires at: %@ refresh token: %@", self.accessToken.accessToken, self.accessToken.expiresAt, self.accessToken.refreshToken);
    if (self.waitingRequests) {
        SPiDDebugLog(@"Found %lu waiting request, running again", [self.waitingRequests count]);
        for (SPiDRequest *request in self.waitingRequests) {
            [request startRequestWithAccessToken];
        }
        self.waitingRequests = nil;
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

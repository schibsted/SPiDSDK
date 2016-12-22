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
#import "NSError+SPiD.h"
#import "SPiDTokenRequest.h"
#import "SPiDStatus.h"
#import "NSData+Base64.h"
#import "SPiDAgreements.h"

@interface SPiDClient ()

/** Runs after logout has been completed, should not be called directly */
- (void)logoutComplete;

/** Builds authorization query

 @return The authorization query parameters
 */
- (NSString *)authorizationQuery;

/** Builds logout query

 @return The logout query parameters
 */
- (NSString *)logoutQuery;

/** Helper method

 @param url The url to handle
 */
- (BOOL)doHandleOpenURL:(NSURL *)url;

@property (nonatomic, strong, readwrite) NSURLSession *URLSession;
@property (nonatomic, strong, readwrite) NSMutableArray *waitingRequests;
@property (nonatomic, strong) SPiDRequest *authorizationRequest;
@property (nonatomic, copy) void (^completionHandler)(NSError *error);

@end

@implementation SPiDClient

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
        NSString *forgotPasswordUrl = [NSString stringWithFormat:@"%@/flow/password?client_id=%@&redirect_uri=%@", [sharedSPiDClientInstance serverURL], clientID, [SPiDUtils urlEncodeQueryParameter:redirectUri]];
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

- (void)browserRedirectAuthorizationWithCompletionHandler:(void (^)(NSError *response))completionHandler {
#if !TARGET_OS_WATCH
    if (self.accessToken) { // we already have a access token
        SPiDDebugLog(@"Already logged in, aborting redirect");
        completionHandler(nil);
    } else {
        self.completionHandler = completionHandler;
        NSURL *requestURL = [self authorizationURLWithQuery];
        SPiDDebugLog(@"Trying to authorize using browser redirect: %@", requestURL);
        [[UIApplication sharedApplication] openURL:requestURL];
    }
#endif
}

- (void)browserRedirectSignupWithCompletionHandler:(void (^)(NSError *response))completionHandler {
#if !TARGET_OS_WATCH
    self.completionHandler = completionHandler;
    NSURL *requestURL = [self forgotPasswordURLWithQuery];
    SPiDDebugLog(@"Trying to authorize using browser redirect: %@", requestURL);
    [[UIApplication sharedApplication] openURL:requestURL];
#endif
}

- (void)browserRedirectForgotPasswordWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    self.completionHandler = completionHandler;
    [self browserRedirectForgotPassword];
}

- (void)browserRedirectForgotPassword {
#if !TARGET_OS_WATCH
    NSURL *requestURL = [self forgotPasswordURLWithQuery];
    SPiDDebugLog(@"Trying to authorize using browser redirect: %@", requestURL);
    [[UIApplication sharedApplication] openURL:requestURL];
#endif
}

- (void)browserRedirectAccountSummary {
#if !TARGET_OS_WATCH
    NSURL *requestURL = [self accountSummaryURL];

    SPiDDebugLog(@"Trying to open account summary: %@", requestURL);
    if([[UIApplication sharedApplication] canOpenURL:requestURL]) {
       [[UIApplication sharedApplication] openURL:requestURL];
    }
#endif
}

- (void)browserRedirectLogoutWithCompletionHandler:(void (^)(NSError *response))completionHandler {
#if !TARGET_OS_WATCH
    self.completionHandler = completionHandler;
    NSURL *requestURL = [self logoutURLWithQuery];
    SPiDDebugLog(@"Trying to logout from SPiD");
    SPiDDebugLog(@"%@", requestURL.absoluteString);
    [[UIApplication sharedApplication] openURL:requestURL];
#endif
}

- (BOOL)handleOpenURL:(NSURL *)url completionHandler:(void (^)(NSError *response))completionHandler {
    self.completionHandler = completionHandler;
    return [self handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    SPiDDebugLog(@"SPiDSDK received url: %@", [url absoluteString]);
    NSString *redirectURLString = [[self redirectURI] absoluteString];
    NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];

    if ([urlString hasPrefix:redirectURLString] && self.completionHandler) {
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

- (SPiDRequest *)logoutRequestWithCompletionHandler:(void (^)(NSError *error))completionHandler {
    @synchronized (self.authorizationRequest) {
        if (self.authorizationRequest == nil) { // can't logout if we are already logging in
            // TODO: We should implement a api endpoint for logout
            NSString *path = [@"/logout" stringByAppendingString:[self logoutQuery]];
            SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:^(SPiDResponse *response) {
                [self logoutComplete];
                
                if(completionHandler) {
                    completionHandler(response.error);
                }
            }];
            return request;
        } else {
            if(completionHandler) {
                completionHandler([NSError sp_apiErrorWithCode:-123 reason:@"SPiD request already in progress" descriptions:nil]);
                // TODO completionHandler( already running);
            }
        }
    }
    return nil;
}

- (NSURL *)authorizationURLWithQuery {
    NSString *query = [self authorizationQuery];
    return [NSURL URLWithString:[self.authorizationURL.absoluteString stringByAppendingString:query]];
}

- (NSURL *)signupURLWithQuery {
    NSString *query = [self authorizationQuery];
    return [NSURL URLWithString:[self.signupURL.absoluteString stringByAppendingString:query]];
}

- (NSURL *)forgotPasswordURLWithQuery {
    //NSString *query = [self getForgotPasswordQuery];
    NSString *query = [self authorizationQuery];
    return [NSURL URLWithString:[self.forgotPasswordURL.absoluteString stringByAppendingString:query]];
}

- (NSURL *)logoutURLWithQuery {
    NSString *query = [self logoutQuery];
    return [NSURL URLWithString:[self.logoutURL.absoluteString stringByAppendingString:query]];
}

- (NSString *)currentUserID {
    if (self.accessToken)
        return self.accessToken.userID;
    return nil;
}

- (BOOL)isAuthorized {
    return [self.accessToken isValid];
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

- (void)oneTimeCodeRequestWithCompletionHandler:(void (^)(SPiDResponse *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/oauth/exchange"];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];

    // TODO: This should be client_id!
    [data setObject:[self serverClientID] forKey:@"clientId"];
    [data setObject:[self serverClientID] forKey:@"client_id"];
    [data setObject:@"code" forKey:@"type"];
    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:path body:data completionHandler:completionHandler];
    [request startRequestWithAccessToken];
}

- (void)sessionCodeRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/oauth/exchange"];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];

    [data setObject:[self serverClientID] forKey:@"clientId"];
    [data setObject:[[self serverRedirectUri] absoluteString] forKey:@"redirectUri"];
    [data setObject:@"session" forKey:@"type"];
    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:path body:data completionHandler:completionHandler];
    [request startRequestWithAccessToken];
}

- (void)meRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/me"];
    SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:completionHandler];
    [request startRequestWithAccessToken];
}

- (void)userRequestWithID:(NSString *)userID completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/user/%@", userID];
    SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:completionHandler];
    [request startRequestWithAccessToken];
}

- (void)currentUserRequestWithCompletionHandler:(void (^)(SPiDResponse *))completionHandler {
    [self userRequestWithID:self.accessToken.userID completionHandler:completionHandler];
}

- (void)userLoginsRequestWithUserID:(NSString *)userID completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/user/%@/logins", userID];
    SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:completionHandler];
    [request startRequestWithAccessToken];
}

- (void)emailStatusWithEmail:(NSString *)email completionHandler:(void (^)(SPiDResponse *responce)) completionHandler {
    NSData *data = [email dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedEmail = [data sp_base64EncodedUrlSafeString];
    
    NSString *path = [NSString stringWithFormat:@"/email/%@/status", encodedEmail];
    SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:completionHandler];
    [request startRequestWithAccessToken];
}

#pragma mark Private methods

///---------------------------------------------------------------------------------------
/// @name Private methods
///---------------------------------------------------------------------------------------

- (id)init {
    if (self = [super init]) {
        self.accessToken = [SPiDKeychainWrapper accessTokenFromKeychainForIdentifier:AccessTokenKeychainIdentification];
        if (![self apiVersionSPiD]) {
            [self setApiVersionSPiD:[NSString stringWithFormat:@"%@", defaultAPIVersionSPiD]];
        }
        [self setUseMobileWeb:YES];
        self.URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (BOOL)doHandleOpenURL:(NSURL *)url {
    NSString *error = [SPiDUtils getUrlParameter:url forKey:@"error"];
    if (error) {
        SPiDDebugLog(@"Received error from SPiD: %@", error)
        if(self.completionHandler) {
            self.completionHandler([NSError sp_oauth2ErrorWithString:error]);
        }
        return NO;
    } else {
        NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
        if ([urlString hasSuffix:@"login"]) {
            NSString *code = [SPiDUtils getUrlParameter:url forKey:@"code"];

            if (code) {
                //NSAssert(code, @"SPiDOAuth2 missing code, this should not happen.");
                SPiDDebugLog(@"Received code: %@", code);
                SPiDTokenRequest *request = [SPiDTokenRequest userTokenRequestWithCode:code completionHandler:self.completionHandler];
                [request start];
            } else {
                // Logout
                if(self.completionHandler) {
                    self.completionHandler([NSError sp_oauth2ErrorWithCode:SPiDUserAbortedLogin reason:@"UserAbortedLogin" descriptions:[NSDictionary dictionaryWithObjectsAndKeys:@"User aborted login", @"error", nil]]);
                }
            }
        } else if ([urlString hasSuffix:@"logout"]) {
            SPiDDebugLog(@"Logged out from SPiD");
            [self logoutComplete];
            if(self.completionHandler) {
                self.completionHandler(nil);
            }
        }
        return YES;
    }
}

- (NSString *)authorizationQuery {
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

- (NSString *)logoutQuery {
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
    if (!self.waitingRequests) {
        self.waitingRequests = [[NSMutableArray alloc] init];
    }
    [self.waitingRequests addObject:request];

    @synchronized (self.authorizationRequest) {
        if (self.authorizationRequest == nil) { // can't logout if we are already logging in
            self.authorizationRequest = [SPiDTokenRequest refreshTokenRequestWithCompletionHandler:^(NSError *error) {
                [self authorizationComplete];
            }];
            [self.authorizationRequest start];
        }
    }
}

- (void)clearAuthorizationRequest {
    @synchronized (self.authorizationRequest) {
        self.authorizationRequest = nil;
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
    [self removeAccessToken];
    [self clearAuthorizationRequest];
    self.waitingRequests = nil;
}

- (void)removeAccessToken {
    self.accessToken = nil;
    [SPiDKeychainWrapper removeAccessTokenFromKeychainForIdentifier:AccessTokenKeychainIdentification];
}

@end

@implementation SPiDClient (Agreements)

- (BOOL)fetchAgreementsWithSuccess:(void (^)(SPiDAgreements *))success andFailure:(void (^)(NSError *))failure {
    if([self.accessToken isClientToken] || !self.accessToken) { return NO; } // Exit early if we don't have a client token or it is a client token.

    NSString *path = [NSString stringWithFormat:@"/user/%@/agreements", self.accessToken.userID];
    [[SPiDRequest apiGetRequestWithPath:path completionHandler:^(SPiDResponse *response) {
        // Any errors in the response?
        if(response.error) {
            // Make sure we have a failure block
            if(!failure) { return; }

            // And relay any errors
            failure(response.error);
        } else {
            // Great, request didn't fail. Try to parse the response.
            SPiDAgreements *agreements = [SPiDAgreements parseAgreementsFrom:response.message];
            if(!agreements) {
                // Make sure we have a failure block and call it.
                if(!failure) { return; }
                failure([NSError errorWithDomain:@"ParseError" code:1337 userInfo:nil]);
            } else {
                // Great success! Make sure we have a success block and call it!
                if(!success) { return; }
                success(agreements);
            }
        }
    }] startRequestWithAccessToken];

    return YES;
}

- (BOOL)acceptAgreementsWithSuccess:(void (^)())success andFailure:(void (^)(NSError *))failure {
    if([self.accessToken isClientToken] || !self.accessToken) { return NO; } // Exit early if we don't have a client token or it is a client token.

    NSString *path = [NSString stringWithFormat:@"/user/%@/agreements/accept", self.accessToken.userID];
    [[SPiDRequest apiPostRequestWithPath:path body:nil completionHandler:^(SPiDResponse *response) {
        // Any errors in the response?
        if(response.error) {
            // Make sure we have a failure block
            if(!failure) { return; }

            // And relay any errors
            failure(response.error);
        } else {
            // Check if we have a successfull result
            NSNumber *result = response.message[@"data"][@"result"];
            if([result isKindOfClass:[NSNumber class]] && result.boolValue) {
                if(!success) { return; }
                success();
            } else {
                if(!failure) { return; }
                failure([NSError errorWithDomain:@"ResultFailure" code:420 userInfo:nil]);
            }
        }

    }] startRequestWithAccessToken];

    return YES;
}

@end

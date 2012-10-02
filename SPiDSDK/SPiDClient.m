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

/** Runs a GET request against the SPiD server

 @param path Path for the request eg _api/2/me_
 @param completionHandler Runs after request is completed
 @see sharedInstance
 */
- (void)startGetRequestWithPath:(NSString *)path andCompletionHandler:(void (^)(SPiDResponse *))completionHandler;

/** Runs after authorixation has been completed, should not be called directly
 @param token Access token returned from SPiD
 */
- (void)authorizationComplete:(SPiDAccessToken *)token;

/** TODO: rename and document */
- (void)doAuthorizationRequestWithCompletionHandler:(void (^)(NSError *))completionHandler;

/** Runs after logout has been completed, should not be called directly */
- (void)logoutComplete;

@end

@implementation SPiDClient {
@private
    NSMutableArray *waitingRequests;
    NSInteger tokenRefreshRetryCount; // TODO: implement retries
    SPiDAuthorizationRequest *authorizationRequest;
    SPiDAccessToken *accessToken;
}

@synthesize clientID = _clientID;
@synthesize clientSecret = _clientSecret;
@synthesize appURLScheme = _appURLScheme;
@synthesize redirectURI = _redirectURI;
@synthesize serverURL = _serverURL;
@synthesize authorizationURL = _authorizationURL;
@synthesize tokenURL = _tokenURL;

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
    andAppURLScheme:(NSString *)appURLScheme
         andSPiDURL:(NSURL *)serverURL {
    [self setClientID:clientID];
    [self setClientSecret:clientSecret];
    [self setServerURL:serverURL];

    NSString *escapedAppURL = [appURLScheme stringByReplacingOccurrencesOfString:@":" withString:@""];
    escapedAppURL = [escapedAppURL stringByReplacingOccurrencesOfString:@"/" withString:@""];
    [self setAppURLScheme:escapedAppURL];

    // Generates URL default urls
    if (![self redirectURI])
        [self setRedirectURI:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", [self appURLScheme]]]];

    if (![self authorizationURL])
        [self setAuthorizationURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/login", [self serverURL]]]];

    if (![self tokenURL])
        [self setTokenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/token", [self serverURL]]]];
}

- (void)authorizationRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    // Sanity check
    NSAssert([self authorizationURL], @"SPiDOAuth2 missing authorization URL.");
    NSAssert([self clientID], @"SPiDOAuth2 missing client ID.");
    NSAssert([self clientSecret], @"SPiDOAuth2 missing client secret.");
    NSAssert([self redirectURI], @"SPiDOAuth2 missing redirect url.");
    NSAssert(!authorizationRequest, @"Authorization request already running");
    // TODO: Should we validate that url starts with https?

    // Check if we have a access token if so do a soft logout before trying to login
    if (accessToken) {
        SPiDDebugLog(@"Access token found, preforming a soft logout to cleanup before login");
        [self softLogoutRequestWithCompletionHandler:^(NSError *error) {
            if (error) {
                completionHandler(error);
            } else {
                [self doAuthorizationRequestWithCompletionHandler:completionHandler];
            }
        }];
    } else { // No access token
        [self doAuthorizationRequestWithCompletionHandler:completionHandler];
    }
}

- (void)doAuthorizationRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    @synchronized (authorizationRequest) {
        authorizationRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
            if (error) {
                // TODO: if error is token expired, refresh
                authorizationRequest = nil;
                completionHandler(error);
            } else {
                [self authorizationComplete:token];
                completionHandler(nil);
            }
        }];
    }
    [authorizationRequest authorize];
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
        }
    } // TODO: check for failure?
    return NO;
}

- (void)logoutRequestWithCompletionHandler:(void (^)(NSError *response))completionHandler {
    @synchronized (authorizationRequest) {
        if (!authorizationRequest) {
            authorizationRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
                if (!error) {
                    [self logoutComplete];
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
                }
                completionHandler(error);
            }];
            [authorizationRequest refreshWithRefreshToken:accessToken];
        }
    }
}

- (NSString *)currentUserID {
    if (accessToken)
        return accessToken.userID;
    return nil;
}

- (BOOL)isLoggedIn {
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

- (void)meRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/api/%@/me", SPiDSKDVersion];
    [self startGetRequestWithPath:path andCompletionHandler:completionHandler];
}

- (void)getUserRequestWithID:(NSString *)userID andCompletionHandler:(void (^)(SPiDResponse *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/api/%@/user/%@", SPiDSKDVersion, userID];
    [self startGetRequestWithPath:path andCompletionHandler:completionHandler];
}

- (void)getUserRequestWithCurrentUserAndCompletionHandler:(void (^)(SPiDResponse *))completionHandler {
    [self getUserRequestWithID:accessToken.userID andCompletionHandler:completionHandler];
}

- (void)loginsRequestWithUserID:(NSString *)userID andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *path = [NSString stringWithFormat:@"/api/%@/user/%@/logins", SPiDSKDVersion, userID];
    [self startGetRequestWithPath:path andCompletionHandler:completionHandler];
}

#pragma mark Private methods
///---------------------------------------------------------------------------------------
/// @name Private methods
///---------------------------------------------------------------------------------------
- (id)init {
    self = [super init];
    if (self) {
        accessToken = [SPiDKeychainWrapper getAccessTokenFromKeychainForIdentifier:AccessTokenKeychainIdentification];
    }
    return self;
}

- (void)startGetRequestWithPath:(NSString *)path andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSAssert(accessToken, @"SPiDOAuth2 missing access token, authorization needed before api request.");
    SPiDRequest *request = [[SPiDRequest alloc] initGetRequestWithPath:path andCompletionHandler:completionHandler];
    if ([accessToken hasTokenExpired]) {
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


- (void)authorizationComplete:(SPiDAccessToken *)token {
    accessToken = token;
    SPiDDebugLog(@"Received access token: %@ expires at: %@ refresh token: %@", [accessToken accessToken], [accessToken expiresAt], [accessToken refreshToken]);

    [SPiDKeychainWrapper storeInKeychainAccessTokenWithValue:token forIdentifier:AccessTokenKeychainIdentification];

    @synchronized (authorizationRequest) {
        authorizationRequest = nil;
    }

    if (waitingRequests) {
        SPiDDebugLog(@"Found %d waiting request, running again", [waitingRequests count]);
        for (SPiDRequest *request in waitingRequests) {
            [request startRequestWithAccessToken:accessToken];
        }
        waitingRequests = nil;
    }
}

- (void)logoutComplete {
    SPiDDebugLog(@"Logged out from SPiD");
    accessToken = nil;

    [SPiDKeychainWrapper removeAccessTokenFromKeychainForIdentifier:AccessTokenKeychainIdentification];

    @synchronized (authorizationRequest) {
        authorizationRequest = nil;
    }

    waitingRequests = nil;
}

@end

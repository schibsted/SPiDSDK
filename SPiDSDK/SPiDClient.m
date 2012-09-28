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

static NSString *const AccessTokenKeychainIdentification = @"AccessToken";

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
@synthesize spidURL = _spidURL;
@synthesize authorizationURL = _authorizationURL;
@synthesize tokenURL = _tokenURL;

#pragma mark Public methods
// Singleton
+ (SPiDClient *)sharedInstance {
    static SPiDClient *sharedSPiDClientInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedSPiDClientInstance = [[self alloc] init];
    });
    return sharedSPiDClientInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        accessToken = [SPiDKeychainWrapper getAccessTokenFromKeychainForIdentifier:AccessTokenKeychainIdentification];
    }
    return self;
}

- (void)setClientID:(NSString *)clientID
    andClientSecret:(NSString *)clientSecret
    andAppURLScheme:(NSString *)appURLScheme
         andSPiDURL:(NSURL *)spidURL {
    [self setClientID:clientID];
    [self setClientSecret:clientSecret];
    [self setAppURLScheme:appURLScheme];
    [self setSpidURL:spidURL];

    // Generates URL default urls
    if (![self redirectURI])
        [self setRedirectURI:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", [self appURLScheme]]]];

    if (![self authorizationURL])
        [self setAuthorizationURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/login", [self spidURL]]]];

    if (![self tokenURL])
        [self setTokenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/token", [self spidURL]]]];
}

- (void)requestSPiDAuthorizationWithCompletionHandler:(SPiDAuthorizationCompletionHandler)completionHandler {
    // Sanity check
    NSAssert([self authorizationURL], @"SPiDOAuth2 missing authorization URL.");
    NSAssert([self clientID], @"SPiDOAuth2 missing client ID.");
    NSAssert([self clientSecret], @"SPiDOAuth2 missing client secret.");
    NSAssert([self redirectURI], @"SPiDOAuth2 missing redirect url.");
    NSAssert(!authorizationRequest, @"Authorization request already running");
    // TODO: Should we validate that url starts with https?

    @synchronized (authorizationRequest) {
        authorizationRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
            if (error) {
                // if error is token expired, refresh
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

- (void)doAuthenticatedMeRequestWithCompletionHandler:(SPiDCompletionHandler)completionHandler {
    NSString *path = [NSString stringWithFormat:@"/api/%@/me", SPiDSKDVersion];
    [self doAuthenticatedGetRequestWithPath:path andCompletionHandler:completionHandler];
}

- (void)doAuthenticatedLoginsRequestWithUserID:(NSString *)userID andCompletionHandler:(SPiDCompletionHandler)completionHandler {
    NSString *path = [NSString stringWithFormat:@"/api/%@/user/%@/logins", SPiDSKDVersion, userID];
    [self doAuthenticatedGetRequestWithPath:path andCompletionHandler:completionHandler];
}

// TODO: logout clears all waiting requests
- (void)doAuthenticatedLogoutRequestWithCompletionHandler:(SPiDAuthorizationCompletionHandler)completionHandler {
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

// TODO: Should keep track of current request and handle if it is a logout
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

#pragma mark Private methods
- (void)doAuthenticatedGetRequestWithPath:(NSString *)path andCompletionHandler:(SPiDCompletionHandler)completionHandler {
    NSAssert(accessToken, @"SPiDOAuth2 missing access token, authorization needed before api request.");
    SPiDRequest *request = [[SPiDRequest alloc] initGetRequestWithPath:path andCompletionHandler:completionHandler];
    if ([accessToken hasTokenExpired]) {
        if (!waitingRequests) {
            waitingRequests = [[NSMutableArray alloc] init];
        }
        [waitingRequests addObject:request];

        [self refreshAccessTokenWithCompletionHandler:^(NSError *error) {
        }];
    } else {
        [request doRequestWithAccessToken:accessToken];
    }
}

- (void)refreshAccessTokenWithCompletionHandler:(SPiDAuthorizationCompletionHandler)completionHandler {
    @synchronized (authorizationRequest) {
        if (!authorizationRequest) {
            authorizationRequest = [[SPiDAuthorizationRequest alloc] initWithCompletionHandler:^(SPiDAccessToken *token, NSError *error) {
                if (!error) {
                    [self authorizationComplete:token];
                }
                completionHandler(error);
            }];
            [authorizationRequest doAccessTokenRefreshWithToken:accessToken];
        }
    }
}

- (void)authorizationComplete:(SPiDAccessToken *)token {
    accessToken = token;
    SPiDDebugLog(@"SPiDSDK received access token: %@ expires at: %@ refresh token: %@", [accessToken accessToken], [accessToken expiresAt], [accessToken refreshToken]);

    [SPiDKeychainWrapper storeInKeychainAccessTokenWithValue:token forIdentifier:AccessTokenKeychainIdentification];

    @synchronized (authorizationRequest) {
        authorizationRequest = nil;
    }

    if (waitingRequests) {
        SPiDDebugLog(@"Found %d waiting request, running again", [waitingRequests count]);
        for (SPiDRequest *request in waitingRequests) {
            [request doRequestWithAccessToken:accessToken];
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

@end

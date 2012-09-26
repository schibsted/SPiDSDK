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

@implementation SPiDClient {
@private
    NSMutableArray *waitingRequests;
    NSInteger tokenRefreshRetryCount;
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

/*
- (BOOL)refreshToken;

- (BOOL)hasTokenExpired;
{
    return ([[NSDate date] earlierDate:expiresAt] == expiresAt);
}
*/

- (void)doAuthenticatedMeRequestWithCompletionHandler:(SPiDCompletionHandler)completionHandler {
    NSAssert(accessToken, @"SPiDOAuth2 missing access token, authorization needed before api request.");
    NSString *path = [NSString stringWithFormat:@"/api/%@/me", SPiDSKDVersion];
    SPiDRequest *request = [[SPiDRequest alloc] initGetRequestWithPath:path andAccessToken:accessToken andCompletionHandler:completionHandler];
    [request doRequest];
}

- (void)doAuthenticatedLoginsRequestWithUserID:(NSString *)userID andCompletionHandler:(SPiDCompletionHandler)completionHandler {
    NSAssert(accessToken, @"SPiDOAuth2 missing access token, authorization needed before api request.");
    NSString *path = [NSString stringWithFormat:@"/api/%@/user/%@/logins", SPiDSKDVersion, userID];
    SPiDRequest *request = [[SPiDRequest alloc] initGetRequestWithPath:path andAccessToken:accessToken andCompletionHandler:completionHandler];
    [request doRequest];
}

// TODO: Should keep track of current request and handle if it is a logout
- (BOOL)handleOpenURL:(NSURL *)url {
#if DEBUG
    NSLog(@"SPiDSDK received url: %@", [url absoluteString]);
#endif
    NSString *redirectURLString = [[self redirectURI] absoluteString];
    NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
    if ([urlString hasPrefix:redirectURLString]) {
        if ([urlString hasSuffix:@"login"]) {
            return [authorizationRequest handleOpenURL:url];
        } else if ([urlString hasSuffix:@"logout"]) {
            [self clearAccessToken];
            return YES;
        }
    } // TODO: check for failure?
    return NO;
}

#pragma mark Private methods
- (void)authorizationComplete:(SPiDAccessToken *)token {
    accessToken = token;
    @synchronized (authorizationRequest) {
        authorizationRequest = nil;
    }
    // TODO: Loop through waiting requests

}

- (void)clearAccessToken {
    accessToken = nil;

    // clear
    /*
    @synchronized (authorizationRequest) {
        authorizationRequest = nil;
    } */
    // TODO: clear keychain

}

@end

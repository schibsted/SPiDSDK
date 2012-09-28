//
//  SPiDAuthorizationRequest.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/21/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

static NSString *const SPiDClientIDKey = @"client_id";
static NSString *const SPiDClientSecretKey = @"client_secret";
static NSString *const SPiDResponseTypeKey = @"response_type";
static NSString *const SPiDGrantTypeKey = @"grant_type";
static NSString *const SPiDRedirectURIKey = @"redirect_uri";
static NSString *const SPiDCodeKey = @"code";
static NSString *const SPiDRefreshTokenKey = @"refresh_token";
static NSString *const SPiDPlatformKey = @"platform";
static NSString *const SPiDForceKey = @"force";

#import "SPiDAuthorizationRequest.h"

@interface SPiDAuthorizationRequest ()
- (NSURL *)generateAuthorizationRequestURL;

- (NSString *)generateAccessTokenPostData;

// NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end

@implementation SPiDAuthorizationRequest

#pragma mark Public methods

- (id)initWithCompletionHandler:(SPiDInternalAuthorizationCompletionHandler)handler {
    self = [super init];
    if (self) {
        completionHandler = handler;
    }
    return self;
}


- (void)authorize {
    NSURL *requestURL = [self generateAuthorizationRequestURL];
    SPiDDebugLog(@"Trying to authorize with SPiD");
    [[UIApplication sharedApplication] openURL:requestURL];
}

- (void)logoutWithAccessToken:(SPiDAccessToken *)accessToken {
    NSURL *requestURL = [self generateLogoutRequestURLWithAccessToken:accessToken];
    SPiDDebugLog(@"Trying to logout from SPiD");
    [[UIApplication sharedApplication] openURL:requestURL];
}

- (void)refreshWithRefreshToken:(SPiDAccessToken *)accessToken {
    NSString *postData = [self generateAccessTokenRefreshPostDataWithAccessToken:accessToken];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[SPiDClient sharedInstance] tokenURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];

    SPiDDebugLog(@"Trying to refresh access tokeb with refresh token: %@", accessToken.refreshToken);

    receivedData = [[NSMutableData alloc] init];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (BOOL)handleOpenURL:url {
    NSString *error = [SPiDUtils getUrlParameter:url forKey:@"error"];
    if (error) {
        SPiDDebugLog(@"SPiDSK: Received error: %@", error);
        completionHandler(nil, [NSError errorWithDomain:@"SPiD" code:1 userInfo:nil]);
        return NO;
    } else {
        NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
        if ([urlString hasSuffix:@"login"]) {
            code = [SPiDUtils getUrlParameter:url forKey:@"code"];
            NSAssert(code, @"SPiDOAuth2 missing code, this should not happen.");
            SPiDDebugLog(@"SPiDSK: Received code: %@", code);
            [self requestAccessToken];
            return YES;
        } else if ([urlString hasSuffix:@"logout"]) {
            completionHandler(nil, nil);
            return YES;
        }
    }
    return NO;
}

#pragma mark Private methods
- (NSURL *)generateAuthorizationRequestURL {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSString *requestURL = [[client authorizationURL] absoluteString];
    requestURL = [requestURL stringByAppendingFormat:@"?%@=%@", SPiDClientIDKey, [client clientID]];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDResponseTypeKey, @"code"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@login", [[client redirectURI] absoluteString]]]];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDPlatformKey, @"mobile"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDForceKey, @"1"]; // TODO: Does this work?
    return [NSURL URLWithString:requestURL];
}

- (NSURL *)generateLogoutRequestURLWithAccessToken:(SPiDAccessToken *)accessToken {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSString *requestURL = @"https://stage.payment.schibsted.no/logout";
    requestURL = [requestURL stringByAppendingFormat:@"?%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@logout", [[client redirectURI] absoluteString]]]];
    requestURL = [requestURL stringByAppendingFormat:@"&oauth_token=%@", accessToken.accessToken];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDPlatformKey, @"mobile"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDForceKey, @"1"]; // TODO: Does this work?
    return [NSURL URLWithString:requestURL];
}

- (NSString *)generateAccessTokenPostData {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSString *data = [NSString string];
    data = [data stringByAppendingFormat:@"%@=%@", SPiDClientIDKey, [client clientID]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@login", [[client redirectURI] absoluteString]]]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDGrantTypeKey, @"authorization_code"];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDClientSecretKey, [client clientSecret]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDCodeKey, code];
    return data;
}

- (NSString *)generateAccessTokenRefreshPostDataWithAccessToken:(SPiDAccessToken *)token {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSString *data = [NSString string];
    data = [data stringByAppendingFormat:@"%@=%@", SPiDClientIDKey, [client clientID]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@login", [[client redirectURI] absoluteString]]]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDGrantTypeKey, @"refresh_token"];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDClientSecretKey, [client clientSecret]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDRefreshTokenKey, token.refreshToken];
    return data;
}

- (void)requestAccessToken {
    NSString *postData = [self generateAccessTokenPostData];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[SPiDClient sharedInstance] tokenURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];

    SPiDDebugLog(@"Running access token request");

    receivedData = [[NSMutableData alloc] init];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];

    code = nil; // Not really needed since the request should only be used once
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    SPiDDebugLog(@"Received response from access token request");
    NSError *jsonError = nil;
    NSDictionary *jsonObject = nil;
    if ([receivedData length] > 0) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:&jsonError];
    }

    if (!jsonError) {
        if ([jsonObject objectForKey:@"error"] && ![[jsonObject objectForKey:@"error"] isEqual:[NSNull null]]) {
            //TODO: return better error
            completionHandler(nil, [NSError errorWithDomain:@"SPiDSDK" code:1 userInfo:nil]);
        } else {
            SPiDAccessToken *accessToken = [[SPiDAccessToken alloc] initWithDictionary:jsonObject];
            completionHandler(accessToken, nil);
        }
    } else {
        SPiDDebugLog(@"SPiDSDK error: %@", [jsonError description]);
        completionHandler(nil, jsonError);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SPiDDebugLog(@"SPiDSDK error: %@", [error description]);
    completionHandler(nil, error);
}

@end
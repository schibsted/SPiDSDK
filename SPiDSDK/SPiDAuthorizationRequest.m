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
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

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
    [[UIApplication sharedApplication] openURL:requestURL];
}

/*
- (id)initRefreshWithAccessToken:(SPiDAccessToken *)accessToken andCompletionHandler:(SPiDInternalAuthorizationCompletionHandler)handler {
    return [self initWithCompletionHandler:handler];
    [self doAccessTokenRefreshWithToken:accessToken];
    return self;
}
*/

- (void)doAccessTokenRefreshWithToken:(SPiDAccessToken *)accessToken {
    NSString *postData = [self generateAccessTokenRefreshPostDataWithAccessToken:accessToken];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[SPiDClient sharedInstance] tokenURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];

    receivedData = [[NSMutableData alloc] init];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (BOOL)handleOpenURL:url {
    NSString *error = [SPiDUtils getUrlParameter:url forKey:@"error"];
    if (error) {
        NSLog(@"SPiDSK: Received error: %@", error);
        // completionHandler to return error!
        return NO;
    } else {
        NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
        NSLog(@"handle: %@", urlString);
        if ([urlString hasSuffix:@"login"]) {
            code = [SPiDUtils getUrlParameter:url forKey:@"code"];
            NSAssert(code, @"SPiDOAuth2 missing code, this should not happen.");
#if DEBUG
            NSLog(@"SPiDSK: Received code: %@", code);
#endif
            [self requestAccessToken];
            return YES;
        } else if ([urlString hasSuffix:@"logout"]) {
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

    receivedData = [[NSMutableData alloc] init];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];

    code = nil; // Not really needed since the request should only be used once
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Request response");
    NSLog(@"URL: %@", [[response URL] absoluteString]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Data received");
    [receivedData appendData:data];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    //NSLog(@"redirecting to : %@", [request URL]);
    //NSString *redirectUrl = [[[SPiDClient sharedInstance] redirectURI] absoluteString];
    // TODO: only needed if not hard logout?
    if ([[[request URL] absoluteString] hasPrefix:@"sdktest://logout"]) {
        // TODO: should check for token when making api calls
        return nil;
    } else {
        return request;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *jsonError = nil;
    NSDictionary *jsonObject = nil;
    if ([receivedData length] > 0) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:&jsonError];
    }

    //TODO: if contains error

    NSLog(@"Request %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    if (!jsonError) {
        NSLog(@"We should now have a valid accessToken");
        SPiDAccessToken *accessToken = [[SPiDAccessToken alloc] initWithDictionary:jsonObject];

        NSLog(@"SPiDSDK recieved access token: %@ expires at: %@ refresh token: %@", [accessToken accessToken], [accessToken expiresAt], [accessToken refreshToken]);

        // TODO: save to keychain
        completionHandler(accessToken, nil); // TODO: add error
    } else {
        NSLog(@"SPiDSDK json error: %@", [jsonError description]);
        completionHandler(nil, jsonError);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"SPiDSDK error: %@", [error description]);
}

@end
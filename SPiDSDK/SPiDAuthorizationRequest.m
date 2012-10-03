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
#import "SPiDExampleApp-Prefix.pch"
#import "NSError+SPiDError.h"

@interface SPiDAuthorizationRequest (PrivateMethods)
/** Generates the authorization URL with GET query

 @return Authorization URL query
 */
- (NSURL *)generateAuthorizationRequestURL;

/** Generates the logout URL with GET query

 @return Logout URL query
 */
- (NSURL *)generateLogoutRequestURLWithAccessToken:(SPiDAccessToken *)accessToken;

/** Generates the access token request data

 @result Access token request data
 */
- (NSString *)generateAccessTokenPostData;

/** Generates the token refresh request data

 @return Token refresh request data
 */
- (NSString *)generateAccessTokenRefreshPostDataWithAccessToken:(SPiDAccessToken *)token;

/** Requests access token by using the received code

 Note: This is used internally and should not be called directly
 */
- (void)requestAccessToken;

// NSURLConnectionDelegate
/** NSURLConnectionDelegate method */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

/** NSURLConnectionDelegate method */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

/** NSURLConnectionDelegate method */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end

@implementation SPiDAuthorizationRequest {
@private
    NSString *code;
    NSMutableData *receivedData;

    void (^completionHandler)(SPiDAccessToken *accessToken, NSError *error);

}

#pragma mark Public methods

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

- (id)initWithCompletionHandler:(void (^)(SPiDAccessToken *accessToken, NSError *error))handler {
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

- (void)softLogoutWithAccessToken:(SPiDAccessToken *)accessToken {
    NSURL *requestURL = [self generateLogoutRequestURLWithAccessToken:accessToken];
    SPiDDebugLog(@"Trying to soft logout from SPiD");
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)refreshWithRefreshToken:(SPiDAccessToken *)accessToken {
    NSString *postData = [self generateAccessTokenRefreshPostDataWithAccessToken:accessToken];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[SPiDClient sharedInstance] tokenURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];

    SPiDDebugLog(@"Trying to refresh access token with refresh token: %@", accessToken.refreshToken);

    receivedData = [[NSMutableData alloc] init];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    NSString *error = [SPiDUtils getUrlParameter:url forKey:@"error"];
    if (error) {
        // TODO: Test GET error
        SPiDDebugLog(@"Received error: %@", error);
        completionHandler(nil, [NSError oauth2ErrorWithString:error]);
        return NO;
    } else {
        NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
        if ([urlString hasSuffix:@"login"]) {
            code = [SPiDUtils getUrlParameter:url forKey:@"code"];

            NSAssert(code, @"SPiDOAuth2 missing code, this should not happen.");
            SPiDDebugLog(@"Received code: %@", code);

            [self requestAccessToken];
        } else if ([urlString hasSuffix:@"logout"]) {
            completionHandler(nil, nil);
        } /*else if ([urlString hasSuffix:@"failure"]) {
            completionHandler(nil, error);
        }*/
        return YES;
    }
    return NO;
}

#pragma mark Private methods

///---------------------------------------------------------------------------------------
/// @name Private methods
///---------------------------------------------------------------------------------------

- (NSURL *)generateAuthorizationRequestURL {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSString *requestURL = [[client authorizationURL] absoluteString];
    requestURL = [requestURL stringByAppendingFormat:@"?%@=%@", SPiDClientIDKey, [client clientID]];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDResponseTypeKey, @"code"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@login", [[client redirectURI] absoluteString]]]];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDPlatformKey, @"mobile"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDForceKey, @"1"];
    return [NSURL URLWithString:requestURL];
}

- (NSURL *)generateLogoutRequestURLWithAccessToken:(SPiDAccessToken *)accessToken {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSString *requestURL = @"https://stage.payment.schibsted.no/logout"; //TODO!!!
    requestURL = [requestURL stringByAppendingFormat:@"?%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@logout", [[client redirectURI] absoluteString]]]];
    requestURL = [requestURL stringByAppendingFormat:@"&oauth_token=%@", accessToken.accessToken];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDPlatformKey, @"mobile"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDForceKey, @"1"];
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

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if ([[[request URL] absoluteString] hasPrefix:[[SPiDClient sharedInstance] appURLScheme]]) {
        SPiDDebugLog(@"Redirecting to : %@", [request URL]);
        return nil;
    }
    return request;
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
            SPiDDebugLog(@"Received error: %@", [jsonError description]);
            NSError *error = [NSError errorFromJSONData:jsonObject];
            completionHandler(nil, error);
        } else {
            SPiDAccessToken *accessToken = [[SPiDAccessToken alloc] initWithDictionary:jsonObject];
            completionHandler(accessToken, nil);
        }
    } else {
        SPiDDebugLog(@"Received error: %@", [jsonError description]);
        completionHandler(nil, jsonError);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SPiDDebugLog(@"Received error: %@", [error description]);
    completionHandler(nil, error);
}

@end
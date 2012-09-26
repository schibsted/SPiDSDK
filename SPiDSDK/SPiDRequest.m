//
//  SPiDRequest.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/17/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDRequest.h"
#import "SPiDAccessToken.h"
#import "SPiDResponse.h"

@interface SPiDRequest ()

// NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end

@implementation SPiDRequest

- (id)initGetRequestWithPath:(NSString *)requestPath andAccessToken:(SPiDAccessToken *)accessToken andCompletionHandler:(SPiDCompletionHandler)handler {
    return [self initRequestWithPath:requestPath andHTTPMethod:@"GET" andHTTPBody:nil andAccessToken:accessToken andCompletionHandler:handler];
}

- (id)initPostRequestWithPath:(NSString *)requestPath andHTTPBody:(NSString *)body andAccessToken:(SPiDAccessToken *)accessToken andCompletionHandler:(SPiDCompletionHandler)handler {
    return [self initRequestWithPath:requestPath andHTTPMethod:@"POST" andHTTPBody:body andAccessToken:accessToken andCompletionHandler:handler];
}

- (id)initRequestWithPath:(NSString *)requestPath andHTTPMethod:(NSString *)method andHTTPBody:(NSString *)body andAccessToken:(SPiDAccessToken *)accessToken andCompletionHandler:(SPiDCompletionHandler)handler {
    self = [super init];
    if (self) {
        NSString *requestURL = [NSString stringWithFormat:@"%@%@", [[[SPiDClient sharedInstance] spidURL] absoluteString], requestPath];
        if ([method isEqualToString:@""] || [method isEqualToString:@"GET"]) { // Default to GET
            NSString *urlStr = [NSString stringWithFormat:@"%@?oauth_token=%@", requestURL, accessToken.accessToken];
            url = [NSURL URLWithString:urlStr];
            httpMethod = @"GET";
        } else if ([method isEqualToString:@"POST"]) {
            url = [NSURL URLWithString:requestURL];
            // TODO: add token to postdata
            httpMethod = @"POST";
            httpBody = body;
        }
        completionHandler = handler;
    }
    return self;
}

// TODO: Should be init methods like /ME
- (void)doAuthenticatedLoginsRequestWithCompletionHandler:(SPiDCompletionHandler)handler andUserID:(NSString *)userID {
    //https://stage.payment.schibsted.no/api/2/user/101912/logins?oauth_token=
    NSString *urlStr = [NSString stringWithFormat:@"https://stage.payment.schibsted.no/api/2/user/%@/logins?oauth_token=%@", userID, @"asdf"];
    url = [NSURL URLWithString:urlStr];
    httpMethod = @"GET";
    completionHandler = handler;
    [self doAuthenticatedSPiDGetRequestWithURL:url];
}

// TODO: Should be in SPiDClient
- (void)doAuthenticatedLogoutRequestWithCompletionHandler:(SPiDCompletionHandler)handler {
    NSLog(@"Trying to logout");
    NSURL *redirectUri = [SPiDUtils urlEncodeString:@"sdktest://logout"];
    NSString *urlStr = [NSString stringWithFormat:@"https://stage.payment.schibsted.no/logout?redirect_uri=%@&oauth_token=%@", [redirectUri absoluteString], @"asdf"];
    url = [NSURL URLWithString:urlStr];
    /*
    if ([[SPiDClient sharedInstance] useWebView]) {
        [self setUrl:url];
        [self setHttpMethod:@"GET"];
        [self doAuthenticatedSPiDGetRequestWithURL:url];
    } else { */
    // Safari redirect
    completionHandler = handler;
    [[UIApplication sharedApplication] openURL:url];
    //}
}

// TODO: Should check token expiration and handle invalid tokens
- (void)doAuthenticatedSPiDGetRequestWithURL:(NSURL *)requestUrl {
    // if expired token, refresh?
    // if not logged in, throw error
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    [request setHTTPMethod:httpMethod];
    NSLog(@"URL: %@", [url absoluteString]);
    receivedData = [[NSMutableData alloc] init];

    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)doRequest {
    receivedData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:httpMethod];
    if (httpBody) {
        [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark Private methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    SPiDResponse *response = [[SPiDResponse alloc] initWithJSONData:receivedData];
    receivedData = nil; // Should not be needed since a request should not be reused
    completionHandler(response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"SPiDSDK error: %@", [error description]);
}

@end
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

- (id)initGetRequestWithPath:(NSString *)requestPath andCompletionHandler:(SPiDCompletionHandler)handler {
    return [self initRequestWithPath:requestPath andHTTPMethod:@"GET" andHTTPBody:nil andCompletionHandler:handler];
}

- (id)initPostRequestWithPath:(NSString *)requestPath andHTTPBody:(NSString *)body andCompletionHandler:(SPiDCompletionHandler)handler {
    return [self initRequestWithPath:requestPath andHTTPMethod:@"POST" andHTTPBody:body andCompletionHandler:handler];
}

- (id)initRequestWithPath:(NSString *)requestPath andHTTPMethod:(NSString *)method andHTTPBody:(NSString *)body andCompletionHandler:(SPiDCompletionHandler)handler {
    self = [super init];
    if (self) {
        NSString *requestURL = [NSString stringWithFormat:@"%@%@", [[[SPiDClient sharedInstance] spidURL] absoluteString], requestPath];
        if ([method isEqualToString:@""] || [method isEqualToString:@"GET"]) { // Default to GET
            url = [NSURL URLWithString:requestURL];
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

// TODO: Should be in SPiDClient
- (void)doAuthenticatedLogoutRequestWithCompletionHandler:(SPiDCompletionHandler)handler {
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
- (void)doRequestWithAccessToken:(SPiDAccessToken *)accessToken {
    NSString *urlStr = [url absoluteString];
    NSString *body;
    if ([httpMethod isEqualToString:@"GET"]) {
        urlStr = [NSString stringWithFormat:@"%@?oauth_token=%@", urlStr, accessToken.accessToken];
    } else if ([httpMethod isEqualToString:@"GET"]) {
        body = [httpBody stringByAppendingFormat:@"&oauth_token=%@"];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:httpMethod];

    SPiDDebugLog(@"Running request: %@", urlStr);

    if (body) {
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }
    receivedData = [[NSMutableData alloc] init];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark Private methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    SPiDDebugLog(@"Recived response from: %@", [url absoluteString]);
    SPiDResponse *response = [[SPiDResponse alloc] initWithJSONData:receivedData];
    receivedData = nil; // Should not be needed since a request should not be reused
    completionHandler(response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SPiDDebugLog(@"SPiDSDK error: %@", [error description]);
}

@end
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
#import "NSError+SPiDError.h"

@interface SPiDRequest (PrivateMethods)

/** 'NSURLConnectionDelegate' method
 
 Sent as a connection loads message incrementally and concatenates the message to the private instance variable 'receivedData'.
 
 @param connection The connection sending the data.
 @param data The newly available data.

 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

/** NSURLConnectionDelegate method 
 
 Sent when a connection has finished loading successfully.
 
 @param connection The connection sending the message.
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

/** NSURLConnectionDelegate method
 
 Sent when a connection fails to load its request successfully.
 
 @param connection The connection sending the message.
 @param error An error object containing details of why the connection failed to load the request successfully.
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end

@implementation SPiDRequest {
@private
    NSURL *url;
    NSString *httpMethod;
    NSString *httpBody;
    NSMutableData *receivedData;


    void (^completionHandler)(SPiDResponse *response);

}

@synthesize retryCount = _retryCount;

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

+ (SPiDRequest *)getRequestWithPath:(NSString *)requestPath andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    return [[self alloc] initRequestWithPath:requestPath andHTTPMethod:@"GET" andHTTPBody:nil andCompletionHandler:completionHandler];
}

+ (SPiDRequest *)postRequestWithPath:(NSString *)requestPath andHTTPBody:(NSDictionary *)body andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    return [[self alloc] initPostRequestWithPath:requestPath andHTTPBody:body andCompletionHandler:completionHandler];
}

+ (SPiDRequest *)requestWithPath:(NSString *)requestPath andHTTPMethod:(NSString *)method andHTTPBody:(NSDictionary *)body andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    return [[self alloc] initRequestWithPath:requestPath andHTTPMethod:method andHTTPBody:body andCompletionHandler:completionHandler];
}

- (id)initGetRequestWithPath:(NSString *)requestPath andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    return [self initRequestWithPath:requestPath andHTTPMethod:@"GET" andHTTPBody:nil andCompletionHandler:completionHandler];
}

- (id)initPostRequestWithPath:(NSString *)requestPath andHTTPBody:(NSDictionary *)body andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    return [self initRequestWithPath:requestPath andHTTPMethod:@"POST" andHTTPBody:body andCompletionHandler:completionHandler];
}

- (id)initRequestWithPath:(NSString *)requestPath andHTTPMethod:(NSString *)method andHTTPBody:(NSDictionary *)body andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    self = [super init];
    if (self) {
        NSString *requestURL = [NSString stringWithFormat:@"%@%@", [[[SPiDClient sharedInstance] serverURL] absoluteString], requestPath];
        if ([method isEqualToString:@""] || [method isEqualToString:@"GET"]) { // Default to GET
            url = [NSURL URLWithString:requestURL];
            httpMethod = @"GET";
        } else if ([method isEqualToString:@"POST"]) {
            url = [NSURL URLWithString:requestURL];
            httpMethod = @"POST";
            httpBody = [self createHTTPBodyForDictionary:body];
        }
        [self setRetryCount:0];
        self->completionHandler = completionHandler;
    }
    return self;
}

- (void)startRequestWithAccessToken:(SPiDAccessToken *)accessToken {
    NSString *urlStr = [url absoluteString];
    NSString *body = @"";
    if ([httpMethod isEqualToString:@"GET"]) {
        urlStr = [NSString stringWithFormat:@"%@?oauth_token=%@", urlStr, accessToken.accessToken];
    } else if ([httpMethod isEqualToString:@"POST"]) {
        if ([httpBody length] > 0) {
            body = [httpBody stringByAppendingFormat:@"&oauth_token=%@", accessToken.accessToken];
        } else {
            body = [httpBody stringByAppendingFormat:@"oauth_token=%@", accessToken.accessToken];
        }
    }

    [self startRequestWithURL:urlStr andBody:body];
}

- (void)startRequest {
    [self startRequestWithURL:[url absoluteString] andBody:httpBody];
}

- (void)startRequestWithURL:(NSString *)urlStr andBody:(NSString *)body {
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

///---------------------------------------------------------------------------------------
/// @name Private methods
///---------------------------------------------------------------------------------------

- (NSString *)createHTTPBodyForDictionary:(NSDictionary *)dictionary {
    NSString *body = @"";
    for (NSString *key in dictionary) {
        if ([body length] > 0) {
            body = [body stringByAppendingFormat:@"&%@=%@", [SPiDUtils urlEncodeString:key], [SPiDUtils urlEncodeString:[dictionary objectForKey:key]]];
        } else {
            body = [body stringByAppendingFormat:@"%@=%@", [SPiDUtils urlEncodeString:key], [SPiDUtils urlEncodeString:[dictionary objectForKey:key]]];
        }
    }
    return body;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    SPiDDebugLog(@"Received response from: %@", [url absoluteString]);
    SPiDResponse *response = [[SPiDResponse alloc] initWithJSONData:receivedData];
    receivedData = nil;
    NSError *error = [response error];
    if (error && ([error code] == SPiDOAuth2InvalidTokenErrorCode || [error code] == SPiDOAuth2ExpiredTokenErrorCode)) {
        if ([self retryCount] < MaxRetryAttempts) {
            SPiDDebugLog(@"Invalid token, trying to refresh");
            [self setRetryCount:[self retryCount] + 1];
            [[SPiDClient sharedInstance] refreshAccessTokenAndRerunRequest:self];
        } else {
            SPiDDebugLog(@"Retried request: %d times, aborting", [self retryCount]);
            completionHandler(response);
        }
    } else {
        completionHandler(response);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SPiDDebugLog(@"SPiDSDK error: %@", [error description]);
    SPiDResponse *response = [[SPiDResponse alloc] initWithError:error];
    completionHandler(response);
}

@end
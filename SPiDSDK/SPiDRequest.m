//
//  SPiDRequest.m
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDRequest.h"
#import "SPiDSDK.h"
#import "SPiDAccessToken.h"
#import "SPiDResponse.h"
#import "SPiDStatus.h"
#import "NSError+SPiDError.h"

@interface SPiDRequest ()

/** Initializes a GET `SPiDRequest`

 @param requestPath Path to endpoint
 @param completionHandler Called on request completion or error
 @return `SPiDRequest`
*/
- (id)initGetRequestWithPath:(NSString *)requestPath completionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Initializes a POST `SPiDRequest`

 @param requestPath Path to endpoint
 @param body The post body
 @param completionHandler Called on request completion or error
 @return `SPiDRequest`
*/
- (id)initPostRequestWithPath:(NSString *)requestPath body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** Initializes a `SPiDRequest`

 @param requestPath Path to endpoint
 @param method Http request method
 @param body The post body
 @param completionHandler Called on request completion or error
 @return `SPiDRequest`
*/
- (id)initRequestWithPath:(NSString *)requestPath method:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler;

/** 'NSURLConnectionDelegate' method
 
 Sent as a connection loads message incrementally and concatenates the message to the private instance variable '_receivedData'.
 
 @param connection The connection sending the data.
 @param data The newly available data.
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

/** 'NSURLConnectionDelegate' method

 Sent when the connection determines that it must change URLs in order to continue loading a request.

 @param connection The connection sending the message.
 @param request The proposed redirected request.
 @param response The URL response that caused the redirect
 @return The actual URL request to use in light of the redirection response.
 */
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;

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

/** Starts a SPiD request

 @param urlStr The url as a string
 @param body The body
 */
- (void)startRequestWithURL:(NSString *)urlStr body:(NSString *)body;

@end

@implementation SPiDRequest

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

+ (id)apiGetRequestWithPath:(NSString *)requestPath completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *completePath = [NSString stringWithFormat:@"/api/%@%@", [[SPiDClient sharedInstance] apiVersionSPiD], requestPath];
    return [[self alloc] initRequestWithPath:completePath method:@"GET" body:nil completionHandler:completionHandler];
}

+ (id)apiPostRequestWithPath:(NSString *)requestPath body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *completePath = [NSString stringWithFormat:@"/api/%@%@", [[SPiDClient sharedInstance] apiVersionSPiD], requestPath];
    return [[self alloc] initPostRequestWithPath:completePath body:body completionHandler:completionHandler];
}

+ (id)requestWithPath:(NSString *)requestPath method:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    return [[self alloc] initRequestWithPath:requestPath method:method body:body completionHandler:completionHandler];
}

- (void)startRequestWithAccessToken {
    SPiDAccessToken *accessToken = [SPiDClient sharedInstance].accessToken;
    //TODO: Should verify this
    NSString *urlStr = [_url absoluteString];
    NSString *body = @"";
    if ([_httpMethod isEqualToString:@"GET"]) {
        if ([urlStr rangeOfString:@"?"].location == NSNotFound) {
            urlStr = [NSString stringWithFormat:@"%@?oauth_token=%@", urlStr, accessToken.accessToken];
        } else {
            urlStr = [NSString stringWithFormat:@"%@&oauth_token=%@", urlStr, accessToken.accessToken];
        }
    } else if ([_httpMethod isEqualToString:@"POST"]) {
        if ([_httpBody length] > 0) {
            body = [_httpBody stringByAppendingFormat:@"&oauth_token=%@", accessToken.accessToken];
        } else {
            body = [_httpBody stringByAppendingFormat:@"oauth_token=%@", accessToken.accessToken];
        }
    }

    [self startRequestWithURL:urlStr body:body];
}

- (void)startRequest {
    [self startRequestWithURL:[_url absoluteString] body:_httpBody];
}

#pragma mark Private methods

///---------------------------------------------------------------------------------------
/// @name Private methods
///---------------------------------------------------------------------------------------

- (id)initGetRequestWithPath:(NSString *)requestPath completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    return [self initRequestWithPath:requestPath method:@"GET" body:nil completionHandler:completionHandler];
}

- (id)initPostRequestWithPath:(NSString *)requestPath body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    return [self initRequestWithPath:requestPath method:@"POST" body:body completionHandler:completionHandler];
}

- (id)initRequestWithPath:(NSString *)requestPath method:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    self = [super init];
    if (self) {
        NSString *requestURL = [NSString stringWithFormat:@"%@%@", [[[SPiDClient sharedInstance] serverURL] absoluteString], requestPath];
        if ([method isEqualToString:@""] || [method isEqualToString:@"GET"]) { // Default to GET
            _url = [NSURL URLWithString:requestURL];
            _httpMethod = @"GET";
        } else if ([method isEqualToString:@"POST"]) {
            _url = [NSURL URLWithString:requestURL];
            _httpMethod = @"POST";
            _httpBody = [SPiDUtils encodedHttpBodyForDictionary:body];
        }
        [self setRetryCount:0];
        self->_completionHandler = completionHandler;
    }
    return self;
}

- (void)startRequestWithURL:(NSString *)urlStr body:(NSString *)body {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:_httpMethod];

    [request setValue:[SPiDStatus spidUserAgent] forHTTPHeaderField:@"User-Agent"];
    SPiDDebugLog(@"Running request: %@", urlStr);

    if (body) {
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }
    _receivedData = [[NSMutableData alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
#pragma clang diagnostic pop
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if ([[[request URL] absoluteString] hasPrefix:[[SPiDClient sharedInstance] appURLScheme]]) {
        SPiDDebugLog(@"Redirecting to: %@", [request URL]);
        return nil;
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    SPiDDebugLog(@"Received response from: %@", [_url absoluteString]);
    SPiDResponse *response = [[SPiDResponse alloc] initWithJSONData:_receivedData];
    _receivedData = nil;
    NSError *error = [response error];
    if (error && ([error code] == SPiDOAuth2InvalidTokenErrorCode || [error code] == SPiDOAuth2ExpiredTokenErrorCode)) {
        if ([self retryCount] < 3) {
            SPiDDebugLog(@"Invalid token, trying to refresh");
            [self setRetryCount:[self retryCount] + 1];
            [[SPiDClient sharedInstance] refreshAccessTokenAndRerunRequest:self];
        } else {
            SPiDDebugLog(@"Retried request: %d times, aborting", [self retryCount]);
            if (_completionHandler != nil)
                _completionHandler(response);
        }
    } else {
        if (_completionHandler != nil)
            _completionHandler(response);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SPiDDebugLog(@"SPiDSDK error: %@", [error description]);
    SPiDResponse *response = [[SPiDResponse alloc] initWithError:error];
    if (_completionHandler != nil)
        _completionHandler(response);
}

@end

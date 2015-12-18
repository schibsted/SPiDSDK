//
//  SPiDRequest.m
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDRequest.h"
#import "SPiDAccessToken.h"
#import "SPiDResponse.h"
#import "NSError+SPiD.h"
#import "SPiDStatus.h"
#import "NSURLRequest+SPiD.h"

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

/** Starts a SPiD request

 @param urlStr The url as a string
 @param body The body
 */
- (void)startWithRequest:(NSURLRequest *)request;

@property (nonatomic, strong, readwrite) NSURL *URL;
@property (nonatomic, strong, readwrite) NSString *HTTPMethod;
@property (nonatomic, strong, readwrite) NSString *HTTPBody;
@property (nonatomic, copy) void (^completionHandler)(SPiDResponse *response);

@end

@implementation SPiDRequest

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

+ (instancetype)apiGetRequestWithPath:(NSString *)requestPath completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *completePath = [NSString stringWithFormat:@"/api/%@%@", [[SPiDClient sharedInstance] apiVersionSPiD], requestPath];
    return [[self alloc] initRequestWithPath:completePath method:@"GET" body:nil completionHandler:completionHandler];
}

+ (instancetype)apiPostRequestWithPath:(NSString *)requestPath body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSString *completePath = [NSString stringWithFormat:@"/api/%@%@", [[SPiDClient sharedInstance] apiVersionSPiD], requestPath];
    return [[self alloc] initPostRequestWithPath:completePath body:body completionHandler:completionHandler];
}

+ (instancetype)requestWithPath:(NSString *)requestPath method:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    return [[self alloc] initRequestWithPath:requestPath method:method body:body completionHandler:completionHandler];
}

- (void)startRequestWithAccessToken {
    SPiDAccessToken *accessToken = [SPiDClient sharedInstance].accessToken;
    //TODO: Should verify this
    NSString *urlStr = [self.URL absoluteString];
    NSString *body = @"";
    if ([self.HTTPMethod isEqualToString:@"GET"]) {
        if ([urlStr rangeOfString:@"?"].location == NSNotFound) {
            urlStr = [NSString stringWithFormat:@"%@?oauth_token=%@", urlStr, accessToken.accessToken];
        } else {
            urlStr = [NSString stringWithFormat:@"%@&oauth_token=%@", urlStr, accessToken.accessToken];
        }
    } else if ([self.HTTPMethod isEqualToString:@"POST"]) {
        if ([self.HTTPBody length] > 0) {
            body = [self.HTTPBody stringByAppendingFormat:@"&oauth_token=%@", accessToken.accessToken];
        } else {
            body = [self.HTTPBody stringByAppendingFormat:@"oauth_token=%@", accessToken.accessToken];
        }
    }

    [self startWithRequest:[NSURLRequest sp_requestWithURL:[NSURL URLWithString:urlStr] method:self.HTTPMethod andBody:self.HTTPBody]];
}

- (void)start {
    [self startWithRequest:[NSURLRequest sp_requestWithURL:self.URL method:self.HTTPMethod andBody:self.HTTPBody]];
}

#pragma mark Private methods

///---------------------------------------------------------------------------------------
/// @name Private methods
///---------------------------------------------------------------------------------------

- (instancetype)initGetRequestWithPath:(NSString *)requestPath completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    return [self initRequestWithPath:requestPath method:@"GET" body:nil completionHandler:completionHandler];
}

- (instancetype)initPostRequestWithPath:(NSString *)requestPath body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    return [self initRequestWithPath:requestPath method:@"POST" body:body completionHandler:completionHandler];
}

- (instancetype)initRequestWithPath:(NSString *)requestPath method:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(SPiDResponse *response))completionHandler {
    self = [super init];
    if (self) {
        NSString *requestURL = [NSString stringWithFormat:@"%@%@", [[[SPiDClient sharedInstance] serverURL] absoluteString], requestPath];
        if ([method isEqualToString:@""] || [method isEqualToString:@"GET"]) { // Default to GET
            self.URL = [NSURL URLWithString:requestURL];
            self.HTTPMethod = @"GET";
        } else if ([method isEqualToString:@"POST"]) {
            self.URL = [NSURL URLWithString:requestURL];
            self.HTTPMethod = @"POST";
            self.HTTPBody = [SPiDUtils encodedHttpBodyForDictionary:body];
        }
        [self setRetryCount:0];
        self.completionHandler = completionHandler;
    }
    return self;
}

- (void)startWithRequest:(NSURLRequest *)request {
    SPiDDebugLog(@"Running request: %@", request.URL);
    
    NSURLSessionDataTask *task = [[[SPiDClient sharedInstance] URLSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            SPiDDebugLog(@"SPiDSDK error: %@", [error description]);
            SPiDResponse *response = [[SPiDResponse alloc] initWithError:error];
            if (self.completionHandler)
                self.completionHandler(response);
        } else {
            SPiDDebugLog(@"Received response from: %@", [self.URL absoluteString]);
            SPiDResponse *spidResponse = [[SPiDResponse alloc] initWithJSONData:data];
            NSError *spidError = [spidResponse error];
            if (spidError && ([spidError code] == SPiDOAuth2InvalidTokenErrorCode || [spidError code] == SPiDOAuth2ExpiredTokenErrorCode)) {
                if ([self retryCount] < 3) {
                    SPiDDebugLog(@"Invalid token, trying to refresh");
                    [self setRetryCount:[self retryCount] + 1];
                    [[SPiDClient sharedInstance] refreshAccessTokenAndRerunRequest:self];
                } else {
                    SPiDDebugLog(@"Retried request: %ld times, aborting", [self retryCount]);
                    if (self.completionHandler)
                        self.completionHandler(spidResponse);
                }
            } else {
                if (self.completionHandler)
                    self.completionHandler(spidResponse);
            }
        }
    }];
    
    [task resume];
}

@end
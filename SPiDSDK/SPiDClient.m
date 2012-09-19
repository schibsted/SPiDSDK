//
//  SPiDClient.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDClient.h"

static NSString *const kClientIDKey = @"client_id";
static NSString *const kClientSecretKey = @"client_secret";
static NSString *const kResponseTypeKey = @"response_type";
static NSString *const kGrantTypeKey = @"grant_type";
static NSString *const kRedirectURLKey = @"redirect_uri";

@implementation SPiDClient {
@private
    BOOL isPending;
    NSURL *requestURL;
}

@synthesize clientID = _clientID;
@synthesize clientSecret = _clientSecret;
@synthesize code = _code;
@synthesize accessToken = _accessToken;
@synthesize appURLScheme = _appURLScheme;
@synthesize redirectURL = _redirectURL;
@synthesize failureURL = _failureURL;
@synthesize spidURL = spidURL;
@synthesize authorizationURL = _authorizationURL;
@synthesize tokenURL = _tokenURL;
@synthesize receivedData = _receivedData;
@synthesize completionHandler = _completionHandler;

+ (SPiDClient *)sharedInstance {
    static SPiDClient *sharedSPiDClientInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedSPiDClientInstance = [[self alloc] init];
    });
    return sharedSPiDClientInstance;
}

//
- (void)setClientID:(NSString *)clientID
    andClientSecret:(NSString *)clientSecret
    andAppURLScheme:(NSString *)appURLScheme
         andSPiDURL:(NSURL *)spidURL {
    // TODO: Use call to set property
    self.clientID = clientID;
    self.clientSecret = clientSecret;
    self.appURLScheme = appURLScheme;
    //self.redirectURL = redirectURL;
    self.spidURL = spidURL;
    //self.failureURL = failureURL;
}

- (NSURL *)generateAuthorizationRequestURL {
    NSString *url = [[self authorizationURL] absoluteString];
    url = [SPiDURL addToURL:url parameterKey:kClientIDKey withValue:[self clientID]];
    url = [SPiDURL addToURL:url parameterKey:kResponseTypeKey withValue:@"code"];
    url = [SPiDURL addToURL:url parameterKey:kRedirectURLKey withValue:[[self redirectURL] absoluteString]];
    url = [SPiDURL addToURL:url parameterKey:@"platform" withValue:@"mobile"];
    url = [SPiDURL addToURL:url parameterKey:@"force" withValue:@"1"];
    return [NSURL URLWithString:url];
}

- (NSString *)generateAccessTokenPostData {
    NSString *data = [NSString string];
    data = [data stringByAppendingFormat:@"%@=%@&", kClientIDKey, [self clientID]];
    data = [data stringByAppendingFormat:@"%@=%@&", kRedirectURLKey, [SPiDURL urlEncodeString:[[self redirectURL] absoluteString]]];
    data = [data stringByAppendingFormat:@"%@=%@&", kGrantTypeKey, @"authorization_code"];
    data = [data stringByAppendingFormat:@"%@=%@&", kClientSecretKey, [self clientSecret]];
    data = [data stringByAppendingFormat:@"%@=%@", @"code", [self code]];
    NSLog(@"Postdata: %@", data);
    return data;
}

- (void)requestSPiDAuthorizationWithCompletionHandler:(void (^)())completionHandler {
    // validate parameters
# if DEBUG
    NSLog(@"Authorizing using url: %@", requestURL.absoluteString);
#endif
    requestURL = [self generateAuthorizationRequestURL];

    [self setCompletionHandler:completionHandler];
    [[UIApplication sharedApplication] openURL:requestURL];
}

- (void)requestAccessToken {
#if DEBUG
    NSLog(@"Requesting token");
#endif

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self tokenURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[self generateAccessTokenPostData] dataUsingEncoding:NSUTF8StringEncoding]];
    [self setReceivedData:[[NSMutableData alloc] init]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"response");
    NSLog([[response URL] absoluteString]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Data received");
    [[self receivedData] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Done");
    NSError *jsonError = nil;
    NSLog(@"Client: %@", [self receivedData]);
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[self receivedData] options:kNilOptions error:&jsonError];

    if (!jsonError && [jsonObject objectForKey:@"access_token"]) {
        [self setAccessToken:[jsonObject objectForKey:@"access_token"]];
        NSLog(@"Got access_token: %@", [self accessToken]);
        //SPiDRequest *request = [[SPiDRequest alloc] init];
        self.completionHandler();
        /*[request doAuthenticatedMeRequestWithCompletionHandler:^(NSDictionary *data) {
            NSLog(@"Finished me with data: %@", data);

        }];*/
        //NSLog(@"%@", self.completionHandler);
        //self.completionHandler();
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", [error description]);
}

- (void)handleOpenURL:(NSURL *)url {
    if ([[url absoluteString] hasPrefix:[[self redirectURL] absoluteString]]) {
#if DEBUG
        NSLog(@"Safari redirect url: %@", [url absoluteString]);
#endif
        [self setCode:[SPiDURL getUrlParameter:url forKey:@"code"]];
        [self requestAccessToken];
    } else if ([[url absoluteString] hasPrefix:[[self failureURL] absoluteString]]) {
#if DEBUG
        NSLog(@"Safari failure url: %@", [url absoluteString]);
#endif
    }
}

@end

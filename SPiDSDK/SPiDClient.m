//
//  SPiDClient.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDClient.h"

static NSString *const SPiDClientIDKey = @"client_id";
static NSString *const SPiDClientSecretKey = @"client_secret";
static NSString *const SPiDResponseTypeKey = @"response_type";
static NSString *const SPiDGrantTypeKey = @"grant_type";
static NSString *const SPiDRedirectURLKey = @"redirect_uri";
static NSString *const SPiDCodeKey = @"code";
static NSString *const SPiDPlatformKey = @"platform";
static NSString *const SPiDForceKey = @"force";

@implementation SPiDClient {
@private
    NSURL *requestURL;
}

@synthesize clientID = _clientID;
@synthesize clientSecret = _clientSecret;
@synthesize code = _code;
@synthesize accessToken = _accessToken;
@synthesize appURLScheme = _appURLScheme;
@synthesize redirectURL = _redirectURL;
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
    [self setClientID:clientID];
    [self setClientSecret:clientSecret];
    [self setAppURLScheme:appURLScheme];
    [self setSpidURL:spidURL];

    // Generates URL default urls
    if (![self redirectURL])
        [self setRedirectURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://login", [self appURLScheme]]]];

    if (![self authorizationURL])
        [self setAuthorizationURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/login", [self spidURL]]]];

    if (![self tokenURL])
        [self setTokenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/token", [self spidURL]]]];
}

- (NSURL *)generateAuthorizationRequestURL {
    NSString *url = [[self authorizationURL] absoluteString];
    url = [SPiDURL addToURL:url parameterKey:SPiDClientIDKey withValue:[self clientID]];
    url = [SPiDURL addToURL:url parameterKey:SPiDResponseTypeKey withValue:@"code"];
    url = [SPiDURL addToURL:url parameterKey:SPiDRedirectURLKey withValue:[[self redirectURL] absoluteString]];
    url = [SPiDURL addToURL:url parameterKey:SPiDPlatformKey withValue:@"mobile"];
    url = [SPiDURL addToURL:url parameterKey:SPiDForceKey withValue:@"1"];
    return [NSURL URLWithString:url];
}

- (NSString *)generateAccessTokenPostData {
    NSString *data = [NSString string];
    data = [data stringByAppendingFormat:@"%@=%@&", SPiDClientIDKey, [self clientID]];
    data = [data stringByAppendingFormat:@"%@=%@&", SPiDRedirectURLKey, [SPiDURL urlEncodeString:[[self redirectURL] absoluteString]]];
    data = [data stringByAppendingFormat:@"%@=%@&", SPiDGrantTypeKey, @"authorization_code"];
    data = [data stringByAppendingFormat:@"%@=%@&", SPiDClientSecretKey, [self clientSecret]];
    data = [data stringByAppendingFormat:@"%@=%@", SPiDCodeKey, [self code]];
    return data;
}

- (void)requestSPiDAuthorizationWithCompletionHandler:(SPiDCompletionHandler)completionHandler {
    // Sanity check
    NSAssert([self authorizationURL], @"SPiDOAuth2 missing authorization URL.");
    NSAssert([self clientID], @"SPiDOAuth2 missing client ID.");
    NSAssert([self clientSecret], @"SPiDOAuth2 missing client secret.");
    NSAssert([self redirectURL], @"SPiDOAuth2 missing redirect url.");

    // TODO: Should we validate that url starts with https?

    requestURL = [self generateAuthorizationRequestURL];

#if DEBUG
    NSLog(@"SPiDSDK authorizing using url: %@", requestURL.absoluteString);
#endif

    [self setCompletionHandler:completionHandler];
    [[UIApplication sharedApplication] openURL:requestURL];
}

- (void)requestAccessToken {
    // Sanity check
    NSAssert([self clientID], @"SPiDOAuth2 missing client ID.");
    NSAssert([self redirectURL], @"SPiDOAuth2 missing redirect url.");
    NSAssert([self clientSecret], @"SPiDOAuth2 missing client secret.");
    NSAssert([self code], @"SPiDOAuth2 missing code, this should not happen.");

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self tokenURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    NSString *postString = [self generateAccessTokenPostData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

#if DEBUG
    NSLog(@"SPiDSDK requesting token with url: %@ and postdata: %@", [self tokenURL], postString);
#endif

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
    NSError *jsonError = nil;
    NSLog(@"Client: %@", [self receivedData]);
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[self receivedData] options:kNilOptions error:&jsonError];

    if (!jsonError && [jsonObject objectForKey:@"access_token"]) {
        [self setAccessToken:[jsonObject objectForKey:@"access_token"]];
        NSLog(@"Got access_token: %@", [self accessToken]);
        self.completionHandler(nil);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", [error description]);
}

// TODO: Should keep track of current request and handle if it is a logout
- (BOOL)handleOpenURL:(NSURL *)url {
#if DEBUG
    NSLog(@"SPiDSDK received url: %@", [url absoluteString]);
#endif
    if ([[url absoluteString] hasPrefix:[[self redirectURL] absoluteString]]) {
        [self setCode:[SPiDURL getUrlParameter:url forKey:@"code"]];
        [self requestAccessToken];
        return YES;
    } /*else if ([[url absoluteString] hasPrefix:[[self failureURL] absoluteString]]) {
        return NO;
    }*/
    return YES;
}

@end

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
#import "NSError+SPiDError.h"

@interface SPiDAuthorizationRequest (PrivateMethods) <UIWebViewDelegate>
/** Generates the authorization URL with GET query

 @return Authorization URL query
 */
- (NSURL *)generateAuthorizationURL;

/** Generates the logout URL with GET query

 @param accessToken ´SPiDAccessToken` the should be used for logging out
 @return Logout URL query
 */
- (NSURL *)generateLogoutURLWithAccessToken:(SPiDAccessToken *)accessToken;

/** Requests access token by using the received code

 Note: This is used internally and should not be called directly
 */
- (void)requestAccessToken;

/** 'NSURLConnectionDelegate' method
 
 Sent as a connection loads data incrementally and concatenates the data to the private instance variable '_receivedData'.
 
 @param connection The connection sending the message.
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

/** NSURLConnectionDelegate method

 Sent when the connection determines that it must change URLs in order to continue loading a request.

 @param connection The connection sending the message.
 @param request The proposed redirected request. The delegate should inspect the redirected request to verify that it meets its needs, and create a copy with new attributes to return to the connection if necessary.
 @param response The URL response that caused the redirect. May be nil in cases where this method is not being sent as a result of involving the delegate in redirect processing.
*/
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;

@end

@interface SPiDAuthorizationRequest ()
@property(nonatomic, strong) NSURL *requestURL;

@end

@implementation SPiDAuthorizationRequest {
@private
    NSString *code;
    NSMutableData *receivedData;

    void (^_completionHandler)(SPiDAccessToken *accessToken, NSError *error);

    BOOL isPending;
}
@synthesize requestURL = _requestURL;


#pragma mark Public methods

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

- (id)initWithCompletionHandler:(void (^)(SPiDAccessToken *accessToken, NSError *error))completionHandler {
    self = [super init];
    if (self) {
        _completionHandler = completionHandler;
    }
    return self;
}

- (void)authorizeWithBrowserRedirect {
    [self setRequestURL:[self generateAuthorizationURL]];
    SPiDDebugLog(@"Trying to authorize using browser redirect");
    SPiDDebugLog(@"Request: %@", [[self requestURL] absoluteString]);
    [[UIApplication sharedApplication] openURL:[self requestURL]];
}

- (void)forgotPasswordWithBrowserRedirect {
    [self setRequestURL:[[SPiDClient sharedInstance] lostPasswordURL]];
    SPiDDebugLog(@"Request: %@", [[self requestURL] absoluteString]);
    [[UIApplication sharedApplication] openURL:[self requestURL]];
}

- (void)logoutWithAccessToken:(SPiDAccessToken *)accessToken {
    NSURL *requestURL = [self generateLogoutURLWithAccessToken:accessToken];
    SPiDDebugLog(@"Trying to logout from SPiD");
    [[UIApplication sharedApplication] openURL:requestURL];
}

- (void)softLogoutWithAccessToken:(SPiDAccessToken *)accessToken {
    NSURL *requestURL = [self generateLogoutURLWithAccessToken:accessToken];
    SPiDDebugLog(@"Trying to soft logout from SPiD: %@", requestURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)refreshWithRefreshToken:(SPiDAccessToken *)accessToken {
    NSString *postData = [self generateRefreshPostDataWithAccessToken:accessToken];
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
        _completionHandler(nil, [NSError oauth2ErrorWithString:error]);
        return NO;
    } else {
        NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
        if ([urlString hasSuffix:@"login"]) {
            code = [SPiDUtils getUrlParameter:url forKey:@"code"];

            if (code) {
                //NSAssert(code, @"SPiDOAuth2 missing code, this should not happen.");
                SPiDDebugLog(@"Received code: %@", code);
                [self requestAccessToken];
            } else {
                // Logout
                _completionHandler(nil, [NSError oauth2ErrorWithCode:SPiDUserAbortedLogin description:@"User aborted login" reason:@""]);
            }
        } else if ([urlString hasSuffix:@"logout"]) {
            _completionHandler(nil, nil);
        } /*else if ([urlString hasSuffix:@"failure"]) {
            _completionHandler(nil, error);
        }*/
        return YES;
    }
}

#pragma mark Private methods

///---------------------------------------------------------------------------------------
/// @name Private methods
///---------------------------------------------------------------------------------------

- (NSURL *)generateAuthorizationURL {
    NSString *requestURL = [[[SPiDClient sharedInstance] authorizationURL] absoluteString];
    requestURL = [self getAuthorizationQueryWithURL:requestURL];
    return [NSURL URLWithString:requestURL];
}

- (NSURL *)generateRegistrationURL {
    NSString *requestURL = [[[SPiDClient sharedInstance] registrationURL] absoluteString];
    requestURL = [self getAuthorizationQueryWithURL:requestURL];
    return [NSURL URLWithString:requestURL];
}

- (NSURL *)generateLostPasswordURL {
    NSString *requestURL = [[[SPiDClient sharedInstance] lostPasswordURL] absoluteString];
    requestURL = [self getAuthorizationQueryWithURL:requestURL];
    return [NSURL URLWithString:requestURL];
}

- (NSString *)getAuthorizationQueryWithURL:(NSString *)requestURL {
    SPiDClient *client = [SPiDClient sharedInstance];
    requestURL = [requestURL stringByAppendingFormat:@"?%@=%@", SPiDClientIDKey, [client clientID]];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDResponseTypeKey, @"code"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@spid/login", [[client redirectURI] absoluteString]]]];
    if ([[SPiDClient sharedInstance] useMobileWeb])
        requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDPlatformKey, @"mobile"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDForceKey, @"1"];
    return requestURL;
}

- (NSURL *)generateLogoutURLWithAccessToken:(SPiDAccessToken *)accessToken {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSString *requestURL = [NSString stringWithFormat:@"%@%@", [[client serverURL] absoluteString], @"/logout"];
    requestURL = [requestURL stringByAppendingFormat:@"?%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@spid/logout", [[client redirectURI] absoluteString]]]];
    requestURL = [requestURL stringByAppendingFormat:@"&oauth_token=%@", accessToken.accessToken];
    if ([[SPiDClient sharedInstance] useMobileWeb])
        requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDPlatformKey, @"mobile"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDForceKey, @"1"];
    return [NSURL URLWithString:requestURL];
}

- (NSString *)generateAccessTokenPostData {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSString *data = [NSString string];
    data = [data stringByAppendingFormat:@"%@=%@", SPiDClientIDKey, [client clientID]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@spid/login", [[client redirectURI] absoluteString]]]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDGrantTypeKey, @"authorization_code"];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDClientSecretKey, [client clientSecret]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDCodeKey, code];
    return data;
}

- (NSString *)generateRefreshPostDataWithAccessToken:(SPiDAccessToken *)accessToken {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSString *data = [NSString string];
    data = [data stringByAppendingFormat:@"%@=%@", SPiDClientIDKey, [client clientID]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@spid/login", [[client redirectURI] absoluteString]]]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDGrantTypeKey, @"refresh_token"];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDClientSecretKey, [client clientSecret]];
    data = [data stringByAppendingFormat:@"&%@=%@", SPiDRefreshTokenKey, accessToken.refreshToken];
    return data;
}

- (void)requestAccessToken {
    NSString *postData = [self generateAccessTokenPostData];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[SPiDClient sharedInstance] tokenURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];

    SPiDDebugLog(@"Trying to get access token from code");

    receivedData = [[NSMutableData alloc] init];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];

    code = nil; // Not really needed since the request should only be used once
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if ([[[request URL] absoluteString] hasPrefix:[[SPiDClient sharedInstance] appURLScheme]]) {
        SPiDDebugLog(@"Redirecting to: %@", [request URL]);
        return nil;
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *jsonError = nil;
    NSDictionary *jsonObject = nil;
    SPiDDebugLog(@"Response data: %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    if ([receivedData length] > 0) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:&jsonError];
    } else { // This should only happen when user is logging out
        _completionHandler(nil, nil);
    }

    if (!jsonError) {
        if ([jsonObject objectForKey:@"error"] && ![[jsonObject objectForKey:@"error"] isEqual:[NSNull null]]) {
            NSError *error = [NSError errorFromJSONData:jsonObject];
            _completionHandler(nil, error);
        } else if (receivedData) {
            SPiDAccessToken *accessToken = [[SPiDAccessToken alloc] initWithDictionary:jsonObject];
            _completionHandler(accessToken, nil);
        }
    } else {
        SPiDDebugLog(@"Received jsonerror: %@", [jsonError description]);
        _completionHandler(nil, jsonError);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SPiDDebugLog("Received '%@' with code '%d' and description: %@", [error domain], [error code], [error description]);
    _completionHandler(nil, error);
}

@end
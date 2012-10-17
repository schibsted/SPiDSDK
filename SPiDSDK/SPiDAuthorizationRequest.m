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

/** Generates the access token request data

 @result Access token request data
 */
- (NSString *)generateAccessTokenPostData;

/** Generates the access token refresh request data

 @param accessToken ´SPiDAccessToken` containing the refresh token
 @return Token refresh request data
 */
- (NSString *)generateRefreshPostDataWithAccessToken:(SPiDAccessToken *)accessToken;

/** Requests access token by using the received code

 Note: This is used internally and should not be called directly
 */
- (void)requestAccessToken;

/** 'NSURLConnectionDelegate' method
 
 Sent as a connection loads data incrementally and concatenates the data to the private instance variable 'receivedData'.
 
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

@implementation SPiDAuthorizationRequest {
@private
    NSString *code;
    NSMutableData *receivedData;

    void (^completionHandler)(SPiDAccessToken *accessToken, NSError *error);

    BOOL isPending;
}

#pragma mark Public methods

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

- (id)initWithCompletionHandler:(void (^)(SPiDAccessToken *accessToken, NSError *error))completionHandler {
    self = [super init];
    if (self) {
        self->completionHandler = completionHandler;
    }
    return self;
}


- (void)authorizeWithBrowserRedirect {
    NSURL *requestURL = [self generateAuthorizationURL];
    SPiDDebugLog(@"Trying to authorize using browser redirect");
    SPiDDebugLog(@"Request: %@", [requestURL absoluteString]);
    [[UIApplication sharedApplication] openURL:requestURL];
}

- (UIWebView *)authorizeWithWebView {
    NSURL *requestURL = [self generateAuthorizationURL];
    SPiDDebugLog(@"Trying to authorize using webview");

    UIWebView *webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [webView setDelegate:self];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

    // On iOS 5+, UIWebView will ignore loadHTMLString: if it's followed by
    // a loadRequest: call, so if there is a "loading" message we defer
    // the loadRequest: until after after we've drawn the "loading" message.
    if ([[[SPiDClient sharedInstance] webViewInitialHTML] length] > 0) {
        isPending = YES;
        [webView loadHTMLString:[[SPiDClient sharedInstance] webViewInitialHTML] baseURL:nil];
    } else {
        isPending = NO;
        [webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
    }
    return webView;
}

- (void)logoutWithAccessToken:(SPiDAccessToken *)accessToken {
    NSURL *requestURL = [self generateLogoutURLWithAccessToken:accessToken];
    SPiDDebugLog(@"Trying to logout from SPiD");
    [[UIApplication sharedApplication] openURL:requestURL];
}

- (void)softLogoutWithAccessToken:(SPiDAccessToken *)accessToken {
    NSURL *requestURL = [self generateLogoutURLWithAccessToken:accessToken];
    SPiDDebugLog(@"Trying to soft logout from SPiD");
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
        // TODO: Test GET error
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

- (NSURL *)generateAuthorizationURL {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSString *requestURL = [[client authorizationURL] absoluteString];
    requestURL = [requestURL stringByAppendingFormat:@"?%@=%@", SPiDClientIDKey, [client clientID]];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDResponseTypeKey, @"code"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@spid/login", [[client redirectURI] absoluteString]]]];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDPlatformKey, @"mobile"];
    requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", SPiDForceKey, @"1"];
    return [NSURL URLWithString:requestURL];
}

- (NSURL *)generateLogoutURLWithAccessToken:(SPiDAccessToken *)accessToken {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSString *requestURL = [NSString stringWithFormat:@"%@%@", [[client serverURL] absoluteString], @"/logout"];
    requestURL = [requestURL stringByAppendingFormat:@"?%@=%@", SPiDRedirectURIKey, [SPiDUtils urlEncodeString:[NSString stringWithFormat:@"%@spid/logout", [[client redirectURI] absoluteString]]]];
    requestURL = [requestURL stringByAppendingFormat:@"&oauth_token=%@", accessToken.accessToken];
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    SPiDDebugLog(@"Loading url: %@", [url absoluteString]);
    NSString *error = [SPiDUtils getUrlParameter:url forKey:@"error"];
    if (error) {
        // TODO: Test GET error
        completionHandler(nil, [NSError oauth2ErrorWithString:error]);
        return NO;
    } else if ([[url absoluteString] hasPrefix:[[SPiDClient sharedInstance] appURLScheme]]) {
        NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
        if ([urlString hasSuffix:@"login"]) {
            if ([webView isLoading]) {
                [webView stopLoading];
            }
            code = [SPiDUtils getUrlParameter:url forKey:@"code"];
            if (code) {
                SPiDDebugLog(@"Received code: %@", code);
                [self requestAccessToken];
            } else {
                completionHandler(nil, [NSError oauth2ErrorWithCode:SPiDUserAbortedLogin description:@"User aborted login" reason:@""]);
            }
            return NO;
        } /*else if ([[url absoluteString] hasPrefix:[[self failureURL] absoluteString]]) {
            return NO;
          }*/
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Are we showing a loading screen?
    if (isPending) {
        isPending = NO;
        NSURL *requestURL = [self generateAuthorizationURL];
        [webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // WebKitErrorFrameLoadInterruptedByPolicyChange = 102
    // this is caused by policy change after WebView is finished and can safely be ignored
    if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
        SPiDDebugLog("Received '%@' with code '%d' and description: %@", error.domain, error.code, error.description);
        completionHandler(nil, error);
    }
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
    if ([receivedData length] > 0) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:&jsonError];
    } else { // This should only happen when user is logging out
        completionHandler(nil, nil);
    }

    if (!jsonError) {
        if ([jsonObject objectForKey:@"error"] && ![[jsonObject objectForKey:@"error"] isEqual:[NSNull null]]) {
            NSError *error = [NSError errorFromJSONData:jsonObject];
            completionHandler(nil, error);
        } else if (receivedData) {
            SPiDAccessToken *accessToken = [[SPiDAccessToken alloc] initWithDictionary:jsonObject];
            completionHandler(accessToken, nil);
        }
    } else {
        SPiDDebugLog(@"Received jsonerror: %@", [jsonError description]);
        completionHandler(nil, jsonError);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SPiDDebugLog(@"Received error: %@", [error description]);
    SPiDDebugLog("Received '%@' with code '%d' and description: %@", [error domain], [error code], [error description]);
    completionHandler(nil, error);
}

@end
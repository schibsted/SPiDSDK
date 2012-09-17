//
//  SPiDClient.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDClient.h"
#import "SPiDRequest.h"

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
@synthesize redirectURL = _redirectURL;
@synthesize failureURL = _failureURL;
@synthesize authorizationURL = _authorizationURL;
@synthesize tokenURL = _tokenURL;
@synthesize initialHTMLString = _initialHTMLString;
@synthesize receivedData = _receivedData;

+ (SPiDClient *)sharedInstance {
    static SPiDClient *sharedSPiDClientInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedSPiDClientInstance = [[self alloc] init];
    });
    return sharedSPiDClientInstance;
}

- (void)setClientID:(NSString *)clientID andClientSecret:(NSString *)clientSecret andRedirectURL:(NSURL *)redirectURL {
    self.clientID = clientID;
    self.clientSecret = clientSecret;
    self.redirectURL = redirectURL;
}

- (NSURL *)generateAuthorizationRequestURL {
    NSString *url = [[self authorizationURL] absoluteString];
    url = [SPiDURL addToURL:url parameterKey:kClientIDKey withValue:[self clientID]];
    url = [SPiDURL addToURL:url parameterKey:kResponseTypeKey withValue:@"code"];
    url = [SPiDURL addToURL:url parameterKey:kRedirectURLKey withValue:[[self redirectURL] absoluteString]];
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

- (void)requestAuthorizationCodeByBrowserRedirect {
    // validate parameters
# if DEBUG
    NSLog(@"Authorizing using url: %@", requestURL.absoluteString);
#endif
    requestURL = [self generateAuthorizationRequestURL];

    [[UIApplication sharedApplication] openURL:requestURL];
}

- (void)requestAuthorizationCodeWithAuthorizationURLHandler:(SPiDAuthorizationURLHandler)authorizationURLHandler {
    requestURL = [self generateAuthorizationRequestURL];
# if DEBUG
    NSLog(@"Authorizing using url: %@", requestURL.absoluteString);
#endif
    authorizationURLHandler(requestURL);
}

- (UIWebView *)requestAuthorizationCodeWithWebView {
    requestURL = [self generateAuthorizationRequestURL];
# if DEBUG
    NSLog(@"Authorizing using url: %@", requestURL.absoluteString);
#endif

    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 480, 480)];
    [webView setDelegate:self];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

    // On iOS 5+, UIWebView will ignore loadHTMLString: if it's followed by
    // a loadRequest: call, so if there is a "loading" message we defer
    // the loadRequest: until after after we've drawn the "loading" message.
    if ([[self initialHTMLString] length] > 0) {
        isPending = YES;
        [webView loadHTMLString:[self initialHTMLString] baseURL:nil];
    } else {
        isPending = NO;
        [webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
    }
    return webView;
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
    NSLog(@"%@", [self receivedData]);
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[self receivedData] options:kNilOptions error:&jsonError];

    if (!jsonError && [jsonObject objectForKey:@"access_token"]) {
        [self setAccessToken:[jsonObject objectForKey:@"access_token"]];
        NSLog(@"Got access_token: %@", [self accessToken]);
        SPiDRequest *request = [[SPiDRequest alloc] init];
        [request doAuthenticatedMeRequestWithCompletionHandler:^(NSDictionary *data) {
            NSLog(@"Finished me with data: %@", data);

        }];
    }
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    if ([[url absoluteString] hasPrefix:[[self redirectURL] absoluteString]]) {
#if DEBUG
        NSLog(@"Webview redirect url: %@", [[request URL] absoluteString]);
#endif
        if ([webView isLoading]) {
            [webView stopLoading];
        }
        [self setCode:[SPiDURL getUrlParameter:url forKey:@"code"]];
        [self requestAccessToken];
        return NO;
    } else if ([[url absoluteString] hasPrefix:[[self failureURL] absoluteString]]) {
#if DEBUG
        NSLog(@"Webview failure url: %@", [[request URL] absoluteString]);
#endif
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Are we showing a loading screen?
    if (isPending) {
        isPending = NO;
        [webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
    }
#if DEBUG
    NSLog(@"Finished loading");
#endif
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // WebKitErrorFrameLoadInterruptedByPolicyChange = 102
    // this is caused by policy change after WebView is finished and can safely be ignored
    if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
        NSLog(@"WebViewFailLoadWithError: %@", [error description]);
    }
}

@end

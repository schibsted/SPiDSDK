//
//  SPiDWebView
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDWebView.h"
#import "SPiDClient.h"
#import "SPiDError.h"
#import "SPiDTokenRequest.h"

@interface SPiDWebView ()

/** Creates a SPiDWebView

 @param requestURL The request URL to open
 @return The SPiDWebView
 */
+ (SPiDWebView *)webView:(NSURL *)requestURL;

/** Sent before a web view begins loading a frame.

 @param webView The web view that is about to load a new frame.
 @param request The content location.
 @param navigationType The type of user action that started the load request.
 @return YES if the web view should begin loading content; otherwise, NO .
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

/** Sent after a web view finishes loading a frame.

 @param webView The web view has finished loading.
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView;

/** Sent if a web view failed to load a frame.

 @param webView The web view that failed to load a frame.
 @param error The error that occurred during loading.
*/
- (void)webView:(UIWebView *)webView didFailLoadWithError:(SPiDError *)error;

@end

@implementation SPiDWebView

+ (SPiDWebView *)authorizationWebViewWithCompletionHandler:(void (^)(SPiDError *error))completionHandler {
    NSString *url = [[[SPiDClient sharedInstance] authorizationURLWithQuery] absoluteString];
    url = [url stringByAppendingFormat:@"&webview=1"];
    SPiDDebugLog(@"Trying to authorize using webview");
    SPiDDebugLog(@"URL: %@", url);
    SPiDWebView *webView = [SPiDWebView webView:[NSURL URLWithString:url]];
    webView.completionHandler = completionHandler;
    return webView;
}

+ (SPiDWebView *)signupWebViewWithCompletionHandler:(void (^)(SPiDError *))completionHandler {
    NSString *url = [[[SPiDClient sharedInstance] signupURLWithQuery] absoluteString];
    url = [url stringByAppendingFormat:@"&webview=1"];
    SPiDDebugLog(@"Trying to authorize using webview");
    SPiDDebugLog(@"URL: %@", url);
    SPiDWebView *webView = [SPiDWebView webView:[NSURL URLWithString:url]];
    webView.completionHandler = completionHandler;
    return webView;
}

+ (SPiDWebView *)forgotPasswordWebViewWithCompletionHandler:(void (^)(SPiDError *))completionHandler {
    NSString *url = [[[SPiDClient sharedInstance] forgotPasswordURLWithQuery] absoluteString];
    url = [url stringByAppendingFormat:@"&webview=1"];
    SPiDDebugLog(@"Trying to authorize using webview");
    SPiDDebugLog(@"URL: %@", url);
    SPiDWebView *webView = [SPiDWebView webView:[NSURL URLWithString:url]];
    webView.completionHandler = completionHandler;
    return webView;
}

///---------------------------------------------------------------------------------------
/// @name Private methods
///---------------------------------------------------------------------------------------

+ (SPiDWebView *)webView:(NSURL *)requestURL {
    SPiDWebView *webView = [[SPiDWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [webView setRequestURL:requestURL];
    [webView setDelegate:webView];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    // Not supported in iOS 5
    //[webView setSuppressesIncrementalRendering:YES];

    // On iOS 5+, UIWebView will ignore loadHTMLString: if it's followed by
    // a loadRequest: call, so if there is a "loading" message we defer
    // the loadRequest: until after after we've drawn the "loading" message.
    if ([[[SPiDClient sharedInstance] webViewInitialHTML] length] > 0) {
        webView.isPending = YES;
        [webView loadHTMLString:[[SPiDClient sharedInstance] webViewInitialHTML] baseURL:nil];
    } else {
        webView.isPending = NO;
        [webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
    }
    return webView;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    SPiDDebugLog(@"Loading url: %@", [url absoluteString]);
    NSString *error = [SPiDUtils getUrlParameter:url forKey:@"error"];
    if (error) {
        if ([webView isLoading])
            [webView stopLoading];
        [webView setDelegate:nil];
        _completionHandler([SPiDError oauth2ErrorWithString:error]);
        return NO;
    } else if ([[url absoluteString] hasPrefix:[[SPiDClient sharedInstance] appURLScheme]]) {
        NSString *urlString = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
        if ([urlString hasSuffix:@"login"]) {
            if ([webView isLoading]) {
                [webView stopLoading];
            }
            [webView setDelegate:nil];
            NSString *code = [SPiDUtils getUrlParameter:url forKey:@"code"];
            if (code) {
                SPiDDebugLog(@"Received code: %@", code);
                SPiDTokenRequest *tokenRequest = [SPiDTokenRequest userTokenRequestWithCode:code completionHandler:_completionHandler];
                [tokenRequest startRequest];
                //self.completionHandler(code, nil);
            } else {
                _completionHandler([SPiDError oauth2ErrorWithCode:SPiDUserAbortedLogin reason:@"UserAbortedLogin" descriptions:[NSDictionary dictionaryWithObjectsAndKeys:@"User aborted login", @"error", nil]]);
            }
        } /*else if ([urlString hasSuffix:@"failure"]) {
            _completionHandler(nil, [NSError oauth2ErrorWithString:]);
            return NO;
        }*/
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Are we showing a loading screen?
    if (_isPending) {
        _isPending = NO;
        [webView loadRequest:[NSURLRequest requestWithURL:self.requestURL]];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // WebKitErrorFrameLoadInterruptedByPolicyChange = 102
    // this is caused by policy change after WebView is finished and can safely be ignored
    if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
        if ([webView isLoading])
            [webView stopLoading];
        [webView setDelegate:nil];

        _completionHandler((SPiDError *) error);
    }
}

@end
//
//  SPiDClient.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDURL.h"
#import "SPiDWebView.h"

typedef void (^SPiDAuthorizationURLHandler)(NSURL *preparedURL);

@interface SPiDClient : NSObject <UIWebViewDelegate, NSURLConnectionDelegate>

@property(strong, nonatomic) NSString *clientID;
@property(strong, nonatomic) NSString *clientSecret;
@property(strong, nonatomic) NSString *code;
@property(strong, nonatomic) NSString *accessToken;
@property(strong, nonatomic) NSURL *redirectURL;
@property(strong, nonatomic) NSURL *failureURL;
@property(strong, nonatomic) NSURL *authorizationURL;
@property(strong, nonatomic) NSURL *tokenURL;
@property(strong, nonatomic) NSString *initialHTMLString;
@property(strong, nonatomic) NSMutableData *receivedData;
@property(strong, nonatomic) UIWebView *webView;
@property(copy) void (^completionHandler)(void);
@property BOOL useWebView;

+ (SPiDClient *)sharedInstance;

- (void)setClientID:(NSString *)clientID andClientSecret:(NSString *)clientSecret andRedirectURL:(NSURL *)redirectURL;

- (void)handleOpenURL:(NSURL *)url;

- (void)requestAuthorizationCodeByBrowserRedirectWithCompletionHandler:(void (^)(void))completionHandler;

- (void)requestAuthorizationCodeWithAuthorizationURLHandler:(SPiDAuthorizationURLHandler)authorizationURLHandler;

- (UIWebView *)requestAuthorizationCodeWithWebViewWithCompletionHandler:(void (^)(void))completionHandler;

@end

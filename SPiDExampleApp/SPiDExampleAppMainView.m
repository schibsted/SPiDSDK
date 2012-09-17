//
//  SPiDExampleAppMainView.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDExampleAppMainView.h"

static NSString *const kClientID = @"504dffb6efd04b4512000000";
static NSString *const kClientSecret = @"iossecret";
static NSString *const kRedirectURL = @"sdktest://login";
static NSString *const kAuthorizationURL = @"https://stage.payment.schibsted.no/auth/start";
static NSString *const kFailureURL = @"sdktest://failure";
static NSString *const kTokenURL = @"https://stage.payment.schibsted.no/oauth/token";

@implementation SPiDExampleAppMainView

- (void)viewDidLoad {
    [super viewDidLoad];
    [[SPiDClient sharedInstance] setClientID:kClientID andClientSecret:kClientSecret andRedirectURL:[NSURL URLWithString:kRedirectURL]];
}

- (IBAction)loginByRedirect:(id)sender {
    [[SPiDClient sharedInstance] setAuthorizationURL:[NSURL URLWithString:kAuthorizationURL]];
    [[SPiDClient sharedInstance] requestAuthorizationCodeByBrowserRedirect];
}

- (IBAction)loginByWebView:(id)sender {
    [[SPiDClient sharedInstance] setAuthorizationURL:[NSURL URLWithString:kAuthorizationURL]];
    [[SPiDClient sharedInstance] setFailureURL:[NSURL URLWithString:kFailureURL]];
    [[SPiDClient sharedInstance] setTokenURL:[NSURL URLWithString:kTokenURL]];
    [[SPiDClient sharedInstance] setInitialHTMLString:@"<html><body>Loading</body><html>"];
    UIWebView *webView = [[SPiDClient sharedInstance] requestAuthorizationCodeWithWebView];
    [[self view] addSubview:webView];
}

- (IBAction)loginByNative:(id)sender {

}

@end

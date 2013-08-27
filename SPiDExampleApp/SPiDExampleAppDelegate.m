//
//  SPiDHybridAppDelegate.m
//  SPiDExampleApp
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDExampleAppDelegate.h"

static NSString *const ClientID = @"your-client-id";
static NSString *const ClientSecret = @"your-client-secret";
static NSString *const AppURLScheme = @"your-app-url";
static NSString *const ServerURL = @"your-spidserver-url";

@implementation SPiDExampleAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize loginView = _loginView;
@synthesize mainView = _mainView;
@synthesize useWebView = _useWebView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SPiDClient setClientID:ClientID
               clientSecret:ClientSecret
               appURLScheme:AppURLScheme
                  serverURL:[NSURL URLWithString:ServerURL]];
    [[SPiDClient sharedInstance] setWebViewInitialHTML:@"<html><body>Loading SPiD login page</body></html>"];

    [self setUseWebView:YES]; // As default, logout as logged in through webview

    // Initialize all views
    [self setLoginView:[[SPiDLoginViewController alloc] initWithNibName:@"SPiDLoginView" bundle:nil]];
    [self setMainView:[[SPiDMainViewController alloc] initWithNibName:@"SPiDMainView" bundle:nil]];

    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    [self setNavigationController:[[UINavigationController alloc] initWithRootViewController:[self loginView]]];
    [[self window] setRootViewController:[self navigationController]];

    // Access token was saved in keychain
    if ([[SPiDClient sharedInstance] isAuthorized]) {
        [_navigationController pushViewController:[self mainView] animated:NO];
    }

    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL didSPiDHandleURL = [[SPiDClient sharedInstance] handleOpenURL:url];

    // Always return that the URL was handled by the application
    return YES;
}

@end
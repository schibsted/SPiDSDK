//
//  SPiDHybridAppDelegate.m
//  SPiDNativeApp
//
//  Created by Mikael Lindström on 1/21/13.
//  Copyright (c) 2013 Mikael Lindström. All rights reserved.
//

#import "SPiDNativeAppDelegate.h"
#import "SPiDTokenRequest.h"
#import "MainViewController.h"
#import "SPiDError.h"

static NSString *const ClientID = @"your-client-id";
static NSString *const ClientSecret = @"your-client-secret";
static NSString *const AppURLScheme = @"your-app-url";
static NSString *const ServerURL = @"your-spidserver-url";

@implementation SPiDNativeAppDelegate

@synthesize window = _window;
@synthesize rootNavigationController = _rootNavigationController;
@synthesize authNavigationController = _authNavigationController;
@synthesize alertView = _alertView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SPiDClient setClientID:ClientID
               clientSecret:ClientSecret
               appURLScheme:AppURLScheme
                  serverURL:[NSURL URLWithString:ServerURL]];

    MainViewController *mainViewController = [[MainViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    self.window.rootViewController = self.rootNavigationController;

    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL didSPiDHandleURL = [[SPiDClient sharedInstance] handleOpenURL:url completionHandler:^(SPiDError *error) {
        if (error == nil) {
            if ([SPiDClient sharedInstance].isAuthorized && ![SPiDClient sharedInstance].isClientToken) {
                SPiDDebugLog(@"SPiD login successful");
                [self.rootNavigationController dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            SPiDDebugLog(@"Received error: %@", error.descriptions.description);
        }
    }];

    if (didSPiDHandleURL) {
        SPiDDebugLog(@"SPiDSDK handled incomming URL");
    }
    
    // Always return that the URL was handled by the application
    return YES;
}

- (void)presentLoginViewAnimated:(BOOL)animated {
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    self.authNavigationController = [[UINavigationController alloc] init];
    [self.authNavigationController pushViewController:loginViewController animated:NO];
    [self.rootNavigationController presentViewController:self.authNavigationController animated:animated completion:nil];
}

- (void)showActivityIndicatorAlert:(NSString *)title {
    if (self.alertView) {
        [self dismissAlertView];
    }

    self.alertView = [[UIAlertView alloc] initWithTitle:title
                                                message:nil delegate:self
                                      cancelButtonTitle:nil otherButtonTitles:nil];
    [self.alertView show];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(self.alertView.bounds.size.width / 2, self.alertView.bounds.size.height - 50);
    [indicator startAnimating];
    [self.alertView addSubview:indicator];
}

- (void)showAlertViewWithTitle:(NSString *)title {
    if (self.alertView) {
        [self dismissAlertView];
    }

    self.alertView = [[UIAlertView alloc]
            initWithTitle:title
                  message:nil delegate:nil cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
    [self.alertView show];
}

- (void)dismissAlertView {
    [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    self.alertView = nil;
}

@end
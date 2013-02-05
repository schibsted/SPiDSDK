//
//  AppDelegate.m
//  SPiDNativeApp
//
//  Created by Mikael Lindström on 1/21/13.
//  Copyright (c) 2013 Mikael Lindström. All rights reserved.
//

static NSString *const ClientID = @"your-client-id";
static NSString *const ClientSecret = @"your-client-secret";
static NSString *const AppURLScheme = @"your-app-url";
static NSString *const ServerURL = @"your-spidserver-url";

#import "SPiDNativeAppDelegate.h"
#import "SPiDTokenRequest.h"
#import "MainViewController.h"

@implementation SPiDNativeAppDelegate

@synthesize window = _window;
@synthesize rootNavigationController = _rootNavigationController;
@synthesize authNavigationController = _authNavigationController;
@synthesize alertView = _alertView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[SPiDClient sharedInstance] setClientID:ClientID
                             andClientSecret:ClientSecret
                             andAppURLScheme:AppURLScheme
                                andServerURL:[NSURL URLWithString:ServerURL]];

    MainViewController *mainViewController = [[MainViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    self.window.rootViewController = self.rootNavigationController;

    [self.window makeKeyAndVisible];

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
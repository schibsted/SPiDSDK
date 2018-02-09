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
#import "NSError+SPiD.h"

static NSString *const ClientID = @"your-client-id";
static NSString *const ClientSecret = @"your-client-secret";
static NSString *const AppURLScheme = @"your-app-url";
static NSString *const ServerURL = @"your-spidserver-url";

@implementation SPiDNativeAppDelegate

@synthesize window = _window;
@synthesize rootNavigationController = _rootNavigationController;
@synthesize authNavigationController = _authNavigationController;
@synthesize alertController = _alertController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SPiDClient setClientID:ClientID
               clientSecret:ClientSecret
               appURLScheme:AppURLScheme
                  serverURL:[NSURL URLWithString:ServerURL]
           tokenStorageMode:SPiDTokenStorageModeDefault];

    MainViewController *mainViewController = [[MainViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    self.window.rootViewController = self.rootNavigationController;

    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL didSPiDHandleURL = [[SPiDClient sharedInstance] handleOpenURL:url completionHandler:^(NSError *error) {
        if (error == nil) {
            if ([SPiDClient sharedInstance].isAuthorized && ![SPiDClient sharedInstance].isClientToken) {
                SPiDDebugLog(@"SPiD login successful");
                [self.rootNavigationController dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            SPiDDebugLog(@"Received error: %@", error.userInfo.description);
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

- (void)showActivityIndicatorAlert:(NSString *)title fromController:(UIViewController *)controller {
    if (self.alertController) {
        [self dismissAlertViewFromController:controller];
    }

    self.alertController = [UIAlertController alertControllerWithTitle:title
                                                               message:nil
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [controller presentViewController:self.alertController
                             animated:YES
                           completion:nil];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(135, 65.5);
    [indicator startAnimating];
    [controller.view addSubview:indicator];
}

- (void)showAlertViewWithTitle:(NSString *)title fromController:(UIViewController *)controller {
    if (self.alertController) {
        [self dismissAlertViewFromController:controller];
    }

    self.alertController = [UIAlertController alertControllerWithTitle:title
                                                               message:nil
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [self.alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil]];
    [controller presentViewController:self.alertController
                             animated:YES
                           completion:nil];
}

- (void)dismissAlertViewFromController:(UIViewController *)controller {
    [controller dismissViewControllerAnimated:true completion:nil];
    self.alertController = nil;
}

@end

//
//  SPiDHybridAppDelegate.m
//  SPiDHybridApp
//
//  Copyright (c) 2013 Schibsted Payment. All rights reserved.
//

#import "SPiDHybridAppDelegate.h"
#import "MainViewController.h"
#import "SPiDClient.h"

static NSString *const ClientID = @"your-client-id";
static NSString *const ClientSecret = @"your-client-secret";
static NSString *const AppURLScheme = @"your-app-url";
static NSString *const ServerURL = @"your-spidserver-url";
static NSString *const ServerClientID = @"your-server-client-id";
static NSString *const ServerRedirectURI = @"your-spidserver-redirect-uri";

@implementation SPiDHybridAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    MainViewController *mainViewController = [[MainViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    self.window.rootViewController = self.rootNavigationController;

    [SPiDClient setClientID:ClientID
               clientSecret:ClientSecret
               appURLScheme:AppURLScheme
                  serverURL:[NSURL URLWithString:ServerURL]];
    [[SPiDClient sharedInstance] setServerClientID:ServerClientID];
    [[SPiDClient sharedInstance] setServerRedirectUri:[NSURL URLWithString:ServerRedirectURI]];

    [self.window makeKeyAndVisible];

    return YES;
}

@end

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
#import "SPiDResponse.h"
#import "NSError+SPiDError.h"

@implementation SPiDNativeAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize mainView = _mainView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[SPiDClient sharedInstance] setClientID:ClientID
                             andClientSecret:ClientSecret
                             andAppURLScheme:AppURLScheme
                                andServerURL:[NSURL URLWithString:ServerURL]];

    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    [self setMainView:[[MainViewController alloc] init]];
    [self setNavigationController:[[UINavigationController alloc] initWithRootViewController:[self mainView]]];
    [[self window] setRootViewController:[self navigationController]];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password {
    SPiDTokenRequest *tokenRequest = [SPiDTokenRequest nativeTokenRequestWithUsername:username andPassword:password andCompletionHandler:^(SPiDResponse *response) {
        [[self mainView] dismissLoginAlert];
        NSString *title = @"";

        if (![response error]) {
            title = @"Successfully logged in";
        } else if ([[response error] code] == SPiDOAuth2InvalidClientCredentialsErrorCode) {
            title = @"Invalid client credentials";
        } else {
            title = [NSString stringWithFormat:@"Received error: %@", [[[response error] userInfo] objectForKey:NSLocalizedFailureReasonErrorKey]];
        }

        UIAlertView *alertView = [[UIAlertView alloc]
                initWithTitle:title
                      message:nil delegate:nil cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        [alertView show];
    }];
    [tokenRequest startRequest];
}
@end
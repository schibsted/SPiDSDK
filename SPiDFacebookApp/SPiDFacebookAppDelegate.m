//
//  SPiDFacebookAppDelegate.m
//  SPiDFacebookApp
//
//  Created by Mikael Lindström on 1/21/13.
//  Copyright (c) 2013 Mikael Lindström. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "SPiDFacebookAppDelegate.h"
#import "SPiDClient.h"
#import "MainViewController.h"
#import "FacebookLoginViewController.h"
#import "SPiDTokenRequest.h"

static NSString *const ClientID = @"your-client-id";
static NSString *const ClientSecret = @"your-client-secret";
static NSString *const AppURLScheme = @"your-app-url";
static NSString *const ServerURL = @"your-spidserver-url";
static NSString *const SignSecret = @"your-sign-secret";

@implementation SPiDFacebookAppDelegate

@synthesize window = _window;
@synthesize rootNavigationController = _rootNavigationController;
@synthesize facebookNavigationController = _facebookNavigationController;
@synthesize alertView = _alertView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SPiDClient setClientID:ClientID
               clientSecret:ClientSecret
               appURLScheme:AppURLScheme
                  serverURL:[NSURL URLWithString:ServerURL]];
    [[SPiDClient sharedInstance] setSignSecret:SignSecret];

    MainViewController *mainViewController = [[MainViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    self.window.rootViewController = self.rootNavigationController;

    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)presentFacebookViewAnimated:(BOOL)animated {
    FacebookLoginViewController *loginViewController = [[FacebookLoginViewController alloc] init];
    self.facebookNavigationController = [[UINavigationController alloc] init];
    [self.facebookNavigationController pushViewController:loginViewController animated:NO];
    [self.rootNavigationController presentViewController:self.facebookNavigationController animated:animated completion:nil];
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    [self showActivityIndicatorAlert:@"Logging in to SPiD..."];
    NSArray *permissions = [[NSArray alloc] initWithObjects:
            @"email",
            nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                 FBSessionState state,
                                                 NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

/*
 * Callback for facebook session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                [self dismissAlertView];
                // We have a valid session
                NSLog(@"User session found with access token: %@", [FBSession activeSession].accessToken);
                [self getSPiDToken];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }

    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                initWithTitle:@"Error"
                      message:error.localizedDescription
                     delegate:nil cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)getSPiDToken {
    SPiDTokenRequest *request = [SPiDTokenRequest userTokenRequestWithFacebookAppID:[FBSession activeSession].appID
                                                                      facebookToken:[FBSession activeSession].accessToken
                                                                     expirationDate:[FBSession activeSession].expirationDate
                                                                  completionHandler:^(NSError *tokenError) {
                                                                      if (tokenError) {
                                                                          UIAlertView *alertView = [[UIAlertView alloc]
                                                                                  initWithTitle:@"Error"
                                                                                        message:tokenError.localizedDescription
                                                                                       delegate:nil cancelButtonTitle:@"OK"
                                                                              otherButtonTitles:nil];
                                                                          [alertView show];
                                                                      } else {
                                                                          [self.rootNavigationController dismissViewControllerAnimated:YES completion:nil];
                                                                      }
                                                                  }];
    [request startRequest];
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

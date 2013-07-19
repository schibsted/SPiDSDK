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
#import "SPiDError.h"
#import "SPiDUser.h"
#import "LoginViewController.h"

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
            @"basic_info",
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
                SPiDDebugLog(@"User session found with access token: %@", [FBSession activeSession].accessTokenData.accessToken);
                [self dismissAlertView];
                [self getFacebookUser];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];

            // Check for errors requiring to reopen session
            if (error != nil && error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
                error = nil;
                [self openSessionWithAllowLoginUI:YES];
            } else {
                SPiDDebugLog(@"Received login error from Facebook");
            }
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

- (void)getFacebookUser {
    FBRequest *fbRequest = [FBRequest requestForMe];
    [fbRequest startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary <FBGraphUser> *result, NSError *error) {
        // If we can get a user from the facebook token, use that token and try to login to SPiD
        if (error == nil) {
            [self loginToSPiD];
        }
    }];
}

- (void)loginToSPiD {
    SPiDTokenRequest *request = [SPiDTokenRequest
            userTokenRequestWithFacebookAppID:[FBSession activeSession].appID
                                facebookToken:[FBSession activeSession].accessTokenData.accessToken
                               expirationDate:[FBSession activeSession].accessTokenData.expirationDate
                            completionHandler:^(SPiDError *tokenError) {
                                if (tokenError) {
                                    if (tokenError.code == SPiDOAuth2UnknownUserErrorCode) {
                                        UIAlertView *alertView = [[UIAlertView alloc]
                                                initWithTitle:@"User does not exist"
                                                      message:@"No SPiD user exists for your facebook account, do you want to create a user or attach your facebook to a existing SPiD account?"
                                                     delegate:self cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:nil];
                                        [alertView addButtonWithTitle:@"New user"];
                                        [alertView addButtonWithTitle:@"Existing user"];
                                        [alertView show];
                                    } else {
                                        UIAlertView *alertView = [[UIAlertView alloc]
                                                initWithTitle:@"Error"
                                                      message:[tokenError.descriptions objectForKey:@"error"]
                                                     delegate:nil cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
                                        [alertView show];
                                    }
                                } else {
                                    // Login OK!
                                    [self.rootNavigationController dismissViewControllerAnimated:YES completion:nil];
                                }
                            }];
    [request startRequest];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"New user"]) {
        SPiDDebugLog(@"Trying to create a new user");
        [SPiDUser createAccountWithFacebookAppID:[FBSession activeSession].appID
                                   facebookToken:[FBSession activeSession].accessTokenData.accessToken
                                  expirationDate:[FBSession activeSession].accessTokenData.expirationDate
                               completionHandler:^(SPiDError *error) {
                                   if (error) {
                                       UIAlertView *alertView = [[UIAlertView alloc]
                                               initWithTitle:@"Error"
                                                     message:[error.descriptions objectForKey:@"error"]
                                                    delegate:nil cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                                       [alertView show];
                                   } else {
                                       /*UIAlertView *alertView = [[UIAlertView alloc]
                                               initWithTitle:@"User successfully created"
                                                     message:nil delegate:nil cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                                       [alertView show];*/
                                       // Try to login with the new user
                                       [self loginToSPiD];
                                   }
                               }];
    }
    else if ([title isEqualToString:@"Existing user"]) {
        SPiDFacebookAppDelegate *appDelegate = (SPiDFacebookAppDelegate *) [[UIApplication sharedApplication] delegate];
        LoginViewController *loginUpViewController = [[LoginViewController alloc] init];
        [appDelegate.facebookNavigationController pushViewController:loginUpViewController animated:YES];
    }
    else if ([title isEqualToString:@"Cancel"]) {
        NSLog(@"Login canceled.");
    }
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

//
//  SPiDLoginViewController.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/17/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDLoginViewController.h"
#import "NSError+SPiD.h"
#import "SPiDWebView.h"

@implementation SPiDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"SPiD Example App"];
}

- (IBAction)loginWithBrowserRedirect:(id)sender {
    SPiDExampleAppDelegate *appDelegate = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate setUseWebView:NO];
    [[SPiDClient sharedInstance] browserRedirectAuthorizationWithCompletionHandler:^(NSError *error) {
        if (!error) {
            [[self navigationController] pushViewController:[appDelegate mainView] animated:YES];
        }
    }];
}

- (IBAction)loginWithWebView:(id)sender {
    SPiDExampleAppDelegate *appDelegate = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate setUseWebView:YES];
    UIViewController *webViewController = [[UIViewController alloc] init];
    SPiDWebView *webView = [SPiDWebView authorizationWebViewWithCompletionHandler:^(NSError *error) {
        if (!error) {
            [UIView transitionWithView:[[self navigationController] view] duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                SPiDExampleAppDelegate *app = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
                                [[self navigationController] setNavigationBarHidden:NO animated:NO];
                                [[self navigationController] popToViewController:[[[self navigationController] viewControllers] objectAtIndex:0] animated:NO];
                                [[self navigationController] pushViewController:[app mainView] animated:NO];
                            }
                            completion:NULL];
        } else if ([error code] == SPiDUserAbortedLogin) {
            [UIView transitionWithView:[[self navigationController] view] duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                [[self navigationController] setNavigationBarHidden:NO animated:NO];
                                [[self navigationController] popToViewController:[[[self navigationController] viewControllers] objectAtIndex:0] animated:NO];
                            }
                            completion:NULL];
        } else {
            [UIView transitionWithView:[[self navigationController] view] duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                [[self navigationController] setNavigationBarHidden:NO animated:NO];
                                [[self navigationController] popToViewController:[[[self navigationController] viewControllers] objectAtIndex:0] animated:NO];
                            }
                            completion:NULL];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error loading WebView"
                                                                           message:error.userInfo.description
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            [self presentViewController:alert
                               animated:YES
                             completion:nil];
        }
    }];
    [[webViewController view] addSubview:webView];

    [UIView transitionWithView:[[self navigationController] view] duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [[self navigationController] setNavigationBarHidden:YES animated:NO];
                        [[self navigationController] pushViewController:webViewController animated:NO];
                    }
                    completion:NULL];
}

@end

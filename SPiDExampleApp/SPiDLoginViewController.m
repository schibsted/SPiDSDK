//
//  SPiDLoginViewController.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/17/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDLoginViewController.h"
#import "NSError+SPiDError.h"

@implementation SPiDLoginViewController {
@private
    UIViewController *webViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"SPiD Example App"];
}

- (IBAction)loginWithBrowserRedirect:(id)sender {
    SPiDExampleAppDelegate *appDelegate = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate setUseWebView:NO];
    [[SPiDClient sharedInstance] browserRedirectAuthorizationWithCompletionHandler:^(NSError *error) {
        SPiDExampleAppDelegate *appDelegate = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (!error) {
            [[appDelegate navigationController] pushViewController:[appDelegate mainView] animated:YES];
        }
    }];
}

- (IBAction)loginWithWebView:(id)sender {
    SPiDExampleAppDelegate *appDelegate = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate setUseWebView:YES];
    webViewController = [[UIViewController alloc] init];
    UIWebView *webView = [[SPiDClient sharedInstance] webViewAuthorizationWithCompletionHandler:^(NSError *error) {
        SPiDExampleAppDelegate *appDelegate = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (!error) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[[self navigationController] view] cache:YES];
            [[appDelegate navigationController] setNavigationBarHidden:NO animated:NO];
            [[appDelegate navigationController] popViewControllerAnimated:NO];
            [[appDelegate navigationController] pushViewController:[appDelegate mainView] animated:NO];
            [UIView commitAnimations];
        } else if ([error code] == SPiDUserAbortedLogin) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[[self navigationController] view] cache:YES];
            [[appDelegate navigationController] setNavigationBarHidden:NO animated:NO];
            [[appDelegate navigationController] popToRootViewControllerAnimated:NO];
            [UIView commitAnimations];
        } else {
            NSLog(@"Error loading WebView: %@", [error description]);
        }
    }];
    [[webViewController view] addSubview:webView];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[[self navigationController] view] cache:YES];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [[self navigationController] pushViewController:webViewController animated:NO];
    [UIView commitAnimations];
}

@end

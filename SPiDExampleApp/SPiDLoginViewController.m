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
        if (!error) {
            [[self navigationController] pushViewController:[appDelegate mainView] animated:YES];
        }
    }];
}

- (IBAction)loginWithWebView:(id)sender {
    SPiDExampleAppDelegate *appDelegate = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate setUseWebView:YES];
    webViewController = [[UIViewController alloc] init];
    UIWebView *webView = [[SPiDClient sharedInstance] webViewAuthorizationWithCompletionHandler:^(NSError *error) {
        if (!error) {
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [[self navigationController] setNavigationBarHidden:NO animated:NO];
                                 [[self navigationController] popViewControllerAnimated:NO];
                                 [[self navigationController] pushViewController:[appDelegate mainView] animated:NO];
                                 [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[[self navigationController] view] cache:NO];
                             }
                             completion:^(BOOL finished) {
                             }];
        } else if ([error code] == SPiDUserAbortedLogin) {
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [[self navigationController] setNavigationBarHidden:NO animated:NO];
                                 [[self navigationController] popViewControllerAnimated:NO];
                                 [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[[self navigationController] view] cache:NO];
                             }
                             completion:^(BOOL finished) {
                             }];
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

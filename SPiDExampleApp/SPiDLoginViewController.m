//
//  SPiDLoginViewController.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/17/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDLoginViewController.h"
#import "SPiDError.h"
#import "SPiDWebView.h"

@implementation SPiDLoginViewController {
@private
    //UIViewController *webViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"SPiD Example App"];
}

- (IBAction)loginWithBrowserRedirect:(id)sender {
    SPiDExampleAppDelegate *appDelegate = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate setUseWebView:NO];
    [[SPiDClient sharedInstance] browserRedirectAuthorizationWithCompletionHandler:^(SPiDError *error) {
        if (!error) {
            [[self navigationController] pushViewController:[appDelegate mainView] animated:YES];
        }
    }];
}

- (IBAction)loginWithWebView:(id)sender {
    SPiDExampleAppDelegate *appDelegate = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate setUseWebView:YES];
    UIViewController *webViewController = [[UIViewController alloc] init];
    SPiDWebView *webView = [SPiDWebView authorizationWebViewWithCompletionHandler:^(SPiDError *error) {
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
            [[[UIAlertView alloc] initWithTitle:@"Error loading WebView" message:error.descriptions.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
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

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
            [[self navigationController] popViewControllerAnimated:NO];
            [[self navigationController] pushViewController:[appDelegate mainView] animated:YES];
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
            webViewController = nil;
        } else if ([error code] == SPiDUserAbortedLogin) {
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
            [[self navigationController] popViewControllerAnimated:YES];
            webViewController = nil;
        } else {
            NSLog(@"Error %@", [error description]);
        }
    }];
    [[webViewController view] addSubview:webView];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[self navigationController] pushViewController:webViewController animated:YES];
}


@end

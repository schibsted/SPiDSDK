//
//  MainViewController
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/31/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "MainViewController.h"
#import "SPiDNativeAppDelegate.h"
#import "SPiDClient.h"


@implementation MainViewController

@synthesize logoutButton = _logoutButton;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    if ([[SPiDClient sharedInstance] isAuthorized]) {
        self.title = @"SPiD";
        self.view.backgroundColor = [UIColor colorWithRed:238 / 255.0 green:238 / 255.0 blue:238 / 255.0 alpha:1];

        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        scrollView.alwaysBounceVertical = YES;

        CGFloat horizontalCenter = self.view.frame.size.width / 2;
        self.logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.logoutButton.frame = CGRectMake(horizontalCenter - 145, 120, 290, 43);
        self.logoutButton.titleLabel.shadowColor = [UIColor blackColor];
        self.logoutButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
        [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.logoutButton setBackgroundImage:[UIImage imageNamed:@"red_button.png"] forState:UIControlStateNormal];
        [self.logoutButton addTarget:self action:@selector(logoutFromSPiD:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:self.logoutButton];

        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:scrollView];
    } else {
        SPiDNativeAppDelegate *appDelegate = (SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate presentLoginViewAnimated:NO];
    }
}

- (void)logoutFromSPiD:(id)sender {
    [[SPiDClient sharedInstance] softLogoutRequestWithCompletionHandler:^(NSError *response) {
        // TODO: this is a ugly solution
        [self viewWillDisappear:NO];
        [self viewWillAppear:NO];
        [self viewDidAppear:NO];
    }];
}

@end
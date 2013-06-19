//
//  MainViewController
//  SPiDSDK
//
//  Created by mikaellindstrom on 2/5/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "MainViewController.h"
#import "SPiDClient.h"
#import "SPiDFacebookAppDelegate.h"
#import "SPiDResponse.h"
#import "SPiDRequest.h"
#import "SPiDError.h"


@implementation MainViewController

@synthesize logoutButton = _logoutButton;
@synthesize userLabel = _userLabel;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    if ([[SPiDClient sharedInstance] isAuthorized]) {
        self.title = @"SPiD";
        self.view.backgroundColor = [UIColor colorWithRed:238 / 255.0 green:238 / 255.0 blue:238 / 255.0 alpha:1];

        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        scrollView.alwaysBounceVertical = YES;

        CGFloat horizontalCenter = self.view.frame.size.width / 2;
        self.userLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalCenter - 145, 50, 290, 43)];
        self.userLabel.backgroundColor = [UIColor clearColor];
        self.userLabel.textColor = [UIColor blackColor];
        self.userLabel.textAlignment = NSTextAlignmentCenter;
        self.userLabel.text = @"";
        [self.view addSubview:self.userLabel];

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

        [self getUserName];
    } else {
        SPiDFacebookAppDelegate *appDelegate = (SPiDFacebookAppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate presentFacebookViewAnimated:NO];
        self.userLabel.text = @"";
    }
}

- (void)getUserName {
    SPiDFacebookAppDelegate *appDelegate = (SPiDFacebookAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate showActivityIndicatorAlert:@"Fetching current user..."];
    [[SPiDClient sharedInstance] getCurrentUserRequestWithCompletionHandler:^(SPiDResponse *response) {
        [appDelegate dismissAlertView];
        if (![response error]) {
            NSDictionary *data = [[response message] objectForKey:@"data"];
            NSString *user = [NSString stringWithFormat:@"Welcome %@!", [data objectForKey:@"displayName"]];
            [[self userLabel] setText:user];
        } else {
            [self logoutFromSPiD:self];
            [appDelegate showAlertViewWithTitle:@"An error occured, logging out from SPiD"];
        }
    }];
}

- (void)logoutFromSPiD:(id)sender {
    SPiDRequest *request = [[SPiDClient sharedInstance] logoutRequestWithCompletionHandler:^(SPiDError *response) {
        // TODO: this is a ugly solution
        [self viewWillDisappear:NO];
        [self viewWillAppear:NO];
        [self viewDidAppear:NO];
    }];
    [request startRequestWithAccessToken];
}

@end
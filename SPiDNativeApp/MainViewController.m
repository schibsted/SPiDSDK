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
#import "SPiDResponse.h"
#import "SPiDRequest.h"


@implementation MainViewController

@synthesize logoutButton = _logoutButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.userLabel.text = @"";
    
    // Requires user token
    if ([SPiDClient sharedInstance].isAuthorized && ![SPiDClient sharedInstance].isClientToken) {
        [self getUserName];
    } else {
        SPiDNativeAppDelegate *appDelegate = (SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate presentLoginViewAnimated:NO];
    }
}

- (void)getUserName {
    SPiDNativeAppDelegate *appDelegate = (SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate showActivityIndicatorAlert:@"Fetching current user..." fromController:self completionHandler:^{
        [[SPiDClient sharedInstance] currentUserRequestWithCompletionHandler:^(SPiDResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![response error]) {
                    [appDelegate dismissAlertViewFromController:self completionHandler:^{
                        NSDictionary *data = [[response message] objectForKey:@"data"];
                        NSString *user = [NSString stringWithFormat:@"Welcome %@!", [data objectForKey:@"displayName"]];
                        [[self userLabel] setText:user];
                    }];
                }
            });
        }];
    }];
}

- (void)logoutFromSPiD:(id)sender {
    SPiDRequest *request = [[SPiDClient sharedInstance] logoutRequestWithCompletionHandler:^(NSError *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SPiDNativeAppDelegate *appDelegate = (SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate];
            [appDelegate presentLoginViewAnimated:YES];
            self.userLabel.text = @"";
        });
    }];
    [request startRequestWithAccessToken];
}

@end

//
//  FacebookLoginViewController
//  SPiDSDK
//
//  Created by mikaellindstrom on 2/5/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "FacebookLoginViewController.h"
#import "SPiDFacebookAppDelegate.h"
#import "TermsViewController.h"

@implementation FacebookLoginViewController

@synthesize facebookButton = _facebookButton;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];

    self.title = @"SPiD Facebook Example";
    self.view.backgroundColor = [UIColor colorWithRed:238 / 255.0 green:238 / 255.0 blue:238 / 255.0 alpha:1];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.alwaysBounceVertical = YES;

    CGFloat horizontalCenter = self.view.frame.size.width / 2;
    self.facebookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.facebookButton.frame = CGRectMake(horizontalCenter - 100, 120, 200, 43);
    self.facebookButton.titleLabel.shadowColor = [UIColor blackColor];
    self.facebookButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.facebookButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [self.facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.facebookButton setContentEdgeInsets:UIEdgeInsetsMake(0, 44, 0, 0)];
    [self.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook-login-button-small.png"] forState:UIControlStateNormal];
    [self.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook-login-button-small-pressed.png"] forState:UIControlStateSelected];
    [self.facebookButton addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.facebookButton];

    UILabel *serviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalCenter - 130, 220, 260, 20)];
    serviceLabel.textColor = [UIColor darkGrayColor];
    serviceLabel.backgroundColor = [UIColor clearColor];
    serviceLabel.font = [UIFont systemFontOfSize:12];
    serviceLabel.textAlignment = NSTextAlignmentCenter;
    serviceLabel.text = @"By using this service you are agreeing the";
    [scrollView addSubview:serviceLabel];

    UILabel *termsLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalCenter - 40, 235, 80, 20)];
    termsLabel.textColor = [UIColor darkGrayColor];
    termsLabel.backgroundColor = [UIColor clearColor];
    termsLabel.font = [UIFont boldSystemFontOfSize:12];
    termsLabel.textAlignment = NSTextAlignmentCenter;
    termsLabel.text = @"Terms of use";

    // Open webview when "Terms of use" is clicked
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTermsOfUse:)];
    [termsLabel setUserInteractionEnabled:YES];
    [termsLabel addGestureRecognizer:gesture];
    [scrollView addSubview:termsLabel];

    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:scrollView];
}

- (void)loginWithFacebook:(id)sender {
    SPiDFacebookAppDelegate *facebookAppDelegate = (SPiDFacebookAppDelegate *) [[UIApplication sharedApplication] delegate];
    [facebookAppDelegate openSessionWithAllowLoginUI:YES];
}

- (void)showTermsOfUse:(id)showTermsOfUse {
    TermsViewController *termsViewController = [[TermsViewController alloc] init];
    [self.navigationController pushViewController:termsViewController animated:YES];
}

@end
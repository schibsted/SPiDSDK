//
//  SPiDMainViewController.h
//  SPiDSDK
//
//  Copyright (c) 2013 Mikael Lindström. All rights reserved.
//

#import "SPiDMainViewController.h"
#import "SPiDResponse.h"
#import "SPiDExampleAppDelegate.h"
#import "SPiDTokenRequest.h"


@implementation SPiDMainViewController {
@private
    NSString *userID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"SPiD Example App"];
}

- (void)viewWillAppear:(BOOL)animated {
    [[self userLabel] setText:@"Unknown user"];
    [[self navigationItem] setHidesBackButton:YES];

    [self getUserName];
    [self setTokenExpiresLabel];
}

- (IBAction)oneTimeCodeButtonPressed:(id)sender {
    [self getOneTimeToken];
}


- (IBAction)refreshTokenButtonPressed:(id)sender {
    [self refreshToken];
}

- (IBAction)logoutButtonPressed:(id)sender {
    [self logout];
}


#pragma mark Private methods
- (void)getUserName {
    [[SPiDClient sharedInstance] getCurrentUserRequestWithCompletionHandler:^(SPiDResponse *response) {
        if (![response error]) {
            NSDictionary *data = [[response message] objectForKey:@"data"];
            NSString *user = [NSString stringWithFormat:@"Welcome %@!", [data objectForKey:@"displayName"]];
            userID = [data objectForKey:@"userId"];
            [[self userLabel] setText:user];
        }
    }];
}

- (void)refreshToken {
    SPiDTokenRequest *request = [SPiDTokenRequest refreshTokenRequestWithCompletionHandler:^(SPiDError *error) {
        if (!error) {
            [self setTokenExpiresLabel];
        }
    }];
    [request startRequestWithAccessToken];
}

- (void)getOneTimeToken {
    [[SPiDClient sharedInstance] getOneTimeCodeRequestWithCompletionHandler:^(SPiDResponse *response) {
        if (![response error]) {
            NSDictionary *data = [[response message] objectForKey:@"data"];
            NSString *code = [data objectForKey:@"code"];
            [[self oneTimeCodeLabel] setText:[NSString stringWithFormat:@"One time code: %@", code]];
            [[self oneTimeCodeLabel] sizeToFit];
        }
    }];
}

- (void)setTokenExpiresLabel {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *text = [NSString stringWithFormat:@"Token expires at: %@", [formatter stringFromDate:[[SPiDClient sharedInstance] tokenExpiresAt]]];
    [[self tokenLabel] setText:text];
}

- (void)logout {
    SPiDExampleAppDelegate *appDelegate = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
    SPiDRequest *request;
    if ([appDelegate useWebView]) {
        request = [[SPiDClient sharedInstance] logoutRequestWithCompletionHandler:^(SPiDError *error) {
            if (!error) {
                [UIView transitionWithView:[[self navigationController] view] duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromRight
                                animations:^{
                                    [[self navigationController] popToViewController:[[[self navigationController] viewControllers] objectAtIndex:0] animated:NO];
                                }
                                completion:NULL];
            }
        }];
        [request startRequest];
    } else {
        [[SPiDClient sharedInstance] browserRedirectLogoutWithCompletionHandler:^(SPiDError *error) {
            if (!error) {
                [UIView transitionWithView:[[self navigationController] view] duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromRight
                                animations:^{
                                    [[self navigationController] popToViewController:[[[self navigationController] viewControllers] objectAtIndex:0] animated:NO];
                                }
                                completion:NULL];
            }
        }];
    }
    [[self oneTimeCodeLabel] setText:[NSString stringWithFormat:@"One time code: %@", @"none"]];
}

@end
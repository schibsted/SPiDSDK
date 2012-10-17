//
// Created by mikaellindstrom on 9/17/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SPiDMainViewController.h"
#import "SPiDResponse.h"
#import "SPiDExampleAppDelegate.h"


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
    [[SPiDClient sharedInstance] getUserRequestWithCurrentUserAndCompletionHandler:^(SPiDResponse *response) {
        if (![response error]) {
            NSDictionary *data = [[response message] objectForKey:@"data"];
            NSString *user = [NSString stringWithFormat:@"Welcome %@!", [data objectForKey:@"displayName"]];
            userID = [data objectForKey:@"userId"];
            [[self userLabel] setText:user];
        }
    }];
}

- (void)refreshToken {
    [[SPiDClient sharedInstance] refreshAccessTokenRequestWithCompletionHandler:^(NSError *error) {
        if (!error) {
            [self setTokenExpiresLabel];
        }
    }];
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
    if ([appDelegate useWebView]) {
        [[SPiDClient sharedInstance] softLogoutRequestWithCompletionHandler:^(NSError *error) {
            if (!error) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:1];
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[[self navigationController] view] cache:YES];
                [[self navigationController] popViewControllerAnimated:NO];
                [UIView commitAnimations];
            }
        }];
    } else {
        [[SPiDClient sharedInstance] logoutRequestWithCompletionHandler:^(NSError *error) {
            if (!error) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:1];
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[[self navigationController] view] cache:YES];
                [[self navigationController] popViewControllerAnimated:NO];
                [UIView commitAnimations];
            }
        }];
    }
    [[self oneTimeCodeLabel] setText:[NSString stringWithFormat:@"One time code: %@", @"none"]];
}

@end
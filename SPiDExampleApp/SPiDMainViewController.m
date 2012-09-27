//
// Created by mikaellindstrom on 9/17/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SPiDMainViewController.h"
#import "SPiDResponse.h"


@implementation SPiDMainViewController

@synthesize userID = _userID;

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

- (IBAction)lastLoginButtonPressed:(id)sender {
    [self getLastLogin];
}


- (IBAction)refreshToken:(id)sender {
    [self refreshToken];
}

- (IBAction)logoutFromSPiD:(id)sender {
    [self logout];
}


#pragma mark Private methods
- (void)getUserName {
    [[SPiDClient sharedInstance] doAuthenticatedMeRequestWithCompletionHandler:^(SPiDResponse *response) {
        if (![response error]) {
            NSDictionary *data = [[response data] objectForKey:@"data"];
            NSString *user = [NSString stringWithFormat:@"Welcome %@!", [data objectForKey:@"displayName"]];
            [self setUserID:[data objectForKey:@"userId"]];
            [[self userLabel] setText:user];
            [self getLastLogin];
        }
    }];
}

- (void)getLastLogin {
    [[SPiDClient sharedInstance] doAuthenticatedLoginsRequestWithUserID:[self userID] andCompletionHandler:^(SPiDResponse *response) {
        if (![response error]) {
            NSArray *data = [[response data] objectForKey:@"data"];
            NSDictionary *latestLogin = [data objectAtIndex:0];
            NSString *time = [NSString stringWithFormat:@"Last login: %@", [latestLogin objectForKey:@"created"]];
            NSLog(@"Received time: %@", time);
            [[self loginLabel] setText:time];
        }
    }];
}

- (void)refreshToken {
    [[SPiDClient sharedInstance] refreshAccessTokenWithCompletionHandler:^(NSError *error) {
        if (!error) {
            NSLog(@"Refreshed token");
            [self setTokenExpiresLabel];
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
    [[SPiDClient sharedInstance] doAuthenticatedLogoutRequestWithCompletionHandler:^(NSError *error) {
        if (!error) {
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }
    }];
}

@end
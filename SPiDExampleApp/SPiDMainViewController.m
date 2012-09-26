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

    [[SPiDClient sharedInstance] doAuthenticatedMeRequestWithCompletionHandler:^(SPiDResponse *response) {
        if (![response error]) {
            NSDictionary *data = [[response data] objectForKey:@"data"];
            NSString *user = [NSString stringWithFormat:@"Welcome %@!", [data objectForKey:@"displayName"]];
            [self setUserID:[data objectForKey:@"userId"]];
            [[self userLabel] setText:user];
        }
    }];
}

- (IBAction)sendTimeRequest:(id)sender {
    [[SPiDClient sharedInstance] doAuthenticatedLoginsRequestWithUserID:[self userID] andCompletionHandler:^(SPiDResponse *response) {
        if (![response error]) {
            NSArray *data = [[response data] objectForKey:@"data"];
            NSDictionary *latestLogin = [data objectAtIndex:0];
            NSString *time = [NSString stringWithFormat:@"Last login: %@", [latestLogin objectForKey:@"created"]];
            NSLog(@"Received time: %@", time);
        }
    }];
}

- (IBAction)refreshToken:(id)sender {
    [[SPiDClient sharedInstance] refreshAccessToken];
}

- (IBAction)logoutFromSPiD:(id)sender {
    SPiDRequest *request = [[SPiDRequest alloc] init];
    [request doAuthenticatedLogoutRequestWithCompletionHandler:^(SPiDResponse *response) {
        if (![response error]) {
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }
    }];
}

@end
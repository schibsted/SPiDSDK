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

    SPiDRequest *request = [[SPiDRequest alloc] init];
    [request doAuthenticatedMeRequestWithCompletionHandler:^(SPiDResponse *response, NSError *error) {
        if (!error) {
            //NSDictionary *data = [dict objectForKey:@"data"];
            //NSString *user = [NSString stringWithFormat:@"Welcome %@!", [data objectForKey:@"displayName"]];
            //[self setUserID:[data objectForKey:@"userId"]];
            //[[self userLabel] setText:user];
        }
    }];
}

- (IBAction)sendTimeRequest:(id)sender {
    SPiDRequest *request = [[SPiDRequest alloc] init];
    [request doAuthenticatedLoginsRequestWithCompletionHandler:^(SPiDResponse *dResponse, NSError *error) {
        if (!error) {
            //NSArray *data = [dict objectForKey:@"data"];
            //NSDictionary *latestLogin = [data objectAtIndex:0];
            //NSString *time = [NSString stringWithFormat:@"Last login: %@", [latestLogin objectForKey:@"created"]];
            //NSLog(@"Received time: %@", time);
        }
    }                                                andUserID:[self userID]];
}

- (IBAction)logoutFromSPiD:(id)sender {
    SPiDRequest *request = [[SPiDRequest alloc] init];
    [request doAuthenticatedLogoutRequestWithCompletionHandler:^(SPiDResponse *response, NSError *error) {
        if (!error) {
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }
    }];
}

@end
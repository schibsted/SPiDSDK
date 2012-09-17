//
// Created by mikaellindstrom on 9/17/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SPiDLogoutViewController.h"


@implementation SPiDLogoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Logged into SPiD"];
}

- (void)viewWillAppear:(BOOL)animated {
    [[self tokenLabel] setText:[[SPiDClient sharedInstance] accessToken]];
    [[self userLabel] setText:@"Unknown user"];
    [[self navigationItem] setHidesBackButton:YES];
}

- (IBAction)sendMeRequest:(id)sender {
    SPiDRequest *request = [[SPiDRequest alloc] init];
    [request doAuthenticatedMeRequestWithCompletionHandler:^(NSDictionary *dict) {
        NSDictionary *data = [dict objectForKey:@"data"];
        [[self userLabel] setText:[data objectForKey:@"displayName"]];
    }];
}

- (IBAction)logoutFromSPiD:(id)sender {
    SPiDRequest *request = [[SPiDRequest alloc] init];
    [request doAuthenticatedLogoutRequestWithCompletionHandler:^(NSDictionary *dict) {
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }];
}

@end
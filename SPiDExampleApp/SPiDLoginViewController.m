//
//  SPiDLoginViewController.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/17/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDLoginViewController.h"

@implementation SPiDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Login to SPiD"];
}

- (IBAction)loginByRedirect:(id)sender {

    [[SPiDClient sharedInstance] requestSPiDAuthorizationWithCompletionHandler:^(void) {
        SPiDExampleAppDelegate *appDelegate = (SPiDExampleAppDelegate *) [[UIApplication sharedApplication] delegate];
        [[self navigationController] pushViewController:[appDelegate logoutView] animated:YES];
    }];
}

@end

//
//  SPiDExampleAppMainView.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDExampleAppMainView.h"

static NSString *const kServiceProvider = @"iOSSDK";
static NSString *const kTokenURL = @"https://stage.payment.schibsted.no/oauth/token";
static NSString *const kRedirectURL = @"sdktest://login";
static NSString *const kClientID = @"504dffb6efd04b4512000000";
static NSString *const kClientSecret = @"payment";

@implementation SPiDExampleAppMainView

@synthesize api = _api;
@synthesize loginButton = _loginButton;
@synthesize meButton = _meButton;

- (void) authorizeWithSPiD {
 
    GTMOAuth2Authentication *auth = [GTMOAuth2Authentication authenticationWithServiceProvider:kServiceProvider tokenURL:[NSURL URLWithString:kTokenURL] redirectURI:kRedirectURL clientID:kClientID clientSecret:kClientSecret];

    self.api = [[SPiDAPI alloc ] initWithGTMOauth2Authentication:auth];
    
    UIViewController *viewController = [self.api authorize];
    [[self navigationController] pushViewController:viewController animated:YES];
    
}

- (IBAction)loginToSPiDClicked:(id)sender {
    [self authorizeWithSPiD];
}

- (IBAction)meButtonClicked:(id)sender {
    [self.api doAnAuthenticatedAPIFetch];
}


@end

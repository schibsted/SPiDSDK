//
//  TermsViewController
//  SPiDSDK
//
//  Created by mikaellindstrom on 2/6/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "TermsViewController.h"
#import "SPiDResponse.h"
#import "SPiDRequest.h"

@implementation TermsViewController

@synthesize termsWebView = _termsWebView;
@synthesize alertView = _alertView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Terms of Use";

    self.termsWebView = [[UIWebView alloc] initWithFrame:[[self view] bounds]];
    [self.termsWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:self.termsWebView];

    NSString *path = [NSString stringWithFormat:@"/terms?client_id=%@", [[SPiDClient sharedInstance] clientID]];
    SPiDRequest *request = [SPiDRequest apiGetRequestWithPath:path completionHandler:^(SPiDResponse *response) {
        NSString *terms = [[[response message] objectForKey:@"data"] objectForKey:@"terms"];
        [self.termsWebView loadHTMLString:terms baseURL:nil];
    }];
    [request startRequest];
}

@end
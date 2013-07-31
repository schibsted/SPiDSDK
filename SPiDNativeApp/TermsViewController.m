//
//  TermsViewController
//  SPiDSDK
//
//  Created by mikaellindstrom on 2/4/13.
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
        NSString *terms = [NSString stringWithFormat:
                @"<html>"
                        "<head>"
                        "<style>"
                        "body { text-align: left; color: #666; font-family: Helvetica, Arial, sans-serif; font-size: 13px; }\n"
                        "h2 { counter-reset:section; margin: 20px 0 10px 0; font-size: 14px; }\n"
                        "h3 { margin: 15px 0; font-size: 13px; }\n"
                        "h3:before { counter-increment:section; content: counter(section); margin: 0 10px 0 0; }\n"
                        "h4 { margin: 0; text-decoration: underline; font-weight: normal; font-size: 11px; }\n"
                        "p { margin: 0; padding: 0 0 10px 0; font-size: 11px; }\n"
                        "span { font-size: 11px; }\n"
                        "ul { margin: 0px 0 10px 25px; font-size: 11px; list-style: disc outside none; }\n"
                        "li { list-style: disc outside none; }\n"
                        "a:link, a:visited { color: #666; text-decoration: none; }\n"
                        "a:hover {text-decoration: underline;}"
                        "</style>"
                        "</head>"
                        "<body>"
                        "%@"
                        "</body>"
                        "</html>", [[[response message] objectForKey:@"data"] objectForKey:@"terms"]];
        [self.termsWebView loadHTMLString:terms baseURL:nil];
    }];
    [request startRequest];
}

@end
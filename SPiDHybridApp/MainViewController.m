//
//  MainViewController
//  SPiDHybridApp
//
//  Copyright (c) 2013 Schibsted Payment. All rights reserved.
//

#import "MainViewController.h"
#import "SPiDHybridAppDelegate.h"
#import "SPiDClient.h"
#import "SPiDTokenRequest.h"
#import "SPiDResponse.h"
#import "ModalLoginView.h"
#import "LoadingAlertView.h"
#import "SPiDError.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Hybrid";
    self.view.backgroundColor = [UIColor colorWithRed:238 / 255.0 green:238 / 255.0 blue:238 / 255.0 alpha:1];

    // Load html
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mainpage" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];

    // Setup webview
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.webView setDelegate:self];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@""]];
    [self.view addSubview:self.webView];

    // Setup loadingSpinner spinner
    self.loadingSpinner = [[LoadingAlertView alloc] init];

    // Add login button to navigation bar
    self.loginBarButton = [[UIBarButtonItem alloc]
            initWithTitle:@"Login"
                    style:UIBarButtonItemStyleDone
                   target:self
                   action:@selector(showLoginButtonPressed:)];
    self.navigationItem.rightBarButtonItem = self.loginBarButton;

    if ([[SPiDClient sharedInstance] isAuthorized] && ![[SPiDClient sharedInstance] isClientToken]) {
        self.loginBarButton.title = @"Logout";
        [self.loginBarButton setAction:@selector(logout:)];
        [self showLoadingSpinner];
        [self loginWebView];
    }
}

- (void)showLoadingSpinner {
    if (self.alertView) {
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
        self.alertView = nil;
    }

    CGFloat horizontalCenter = self.view.frame.size.width / 2;
    CGFloat verticalCenter = self.view.frame.size.height / 2;
    CGPoint offset = [self.view convertPoint:CGPointZero toView:nil];
    self.loadingSpinner.center = CGPointMake(horizontalCenter, verticalCenter - offset.y / 2);

    [self.view addSubview:self.loadingSpinner];
}

- (IBAction)showLoginButtonPressed:(id)sender {
    // If logged in, login to the webview
    if ([[SPiDClient sharedInstance] isAuthorized] && ![[SPiDClient sharedInstance] isClientToken]) {
        [self showLoadingSpinner];
        [self loginWebView];
    } else {
        [self showModalLogin];
    }
}

- (void)showAlertViewWithTitle:(NSString *)title {
    if (self.alertView) {
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
        self.alertView = nil;
    }

    self.alertView = [[UIAlertView alloc]
            initWithTitle:title
                  message:nil delegate:nil cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
    [self.alertView show];
}


- (void)login:(id)sender {
    NSString *email = self.modalView.emailTextField.text;
    NSString *password = self.modalView.passwordTextField.text;
    SPiDTokenRequest *tokenRequest = [SPiDTokenRequest userTokenRequestWithUsername:email password:password completionHandler:^(SPiDError *error) {
        [self showLoadingSpinner];
        if (error == nil) {
            // Logged in
            [self loginWebView];
        } else if ([error code] == SPiDOAuth2UnverifiedUserErrorCode) {
            [self showAlertViewWithTitle:@"Unverified user, please check your email"];
        } else if ([error code] == SPiDOAuth2InvalidUserCredentialsErrorCode) {
            [self showAlertViewWithTitle:@"Invalid email and/or password"];
        } else {
            [self showAlertViewWithTitle:[NSString stringWithFormat:@"Received error: %@", error.descriptions.description]];
        }
    }];
    [tokenRequest startRequest];
}

- (void)loginWebView {
    [[SPiDClient sharedInstance] getSessionCodeRequestWithCompletionHandler:^(SPiDResponse *response) {
        if (![response error]) {
            NSDictionary *data = [[response message] objectForKey:@"data"];
            NSString *code = [data objectForKey:@"code"];
            [self dismissModalLogin:nil];

            NSString *serverUrl = [SPiDClient sharedInstance].serverURL.absoluteString;
            NSString *url = [NSString stringWithFormat:@"%@/session/%@", serverUrl, code];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [self.webView loadRequest:request];
        } else {
            [self showAlertViewWithTitle:@"Error logging in to webview"];
        }
    }];
}

- (void)logout:(id)logout {
    SPiDRequest *logoutRequest = [[SPiDClient sharedInstance] logoutRequestWithCompletionHandler:^(SPiDError *response) {
        // Load html
        NSString *path = [[NSBundle mainBundle] pathForResource:@"mainpage" ofType:@"html"];
        NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];

        [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@""]];

        self.loginBarButton.title = @"Login";
        [self.loginBarButton setAction:@selector(showLoginButtonPressed:)];

    }];
    [logoutRequest startRequestWithAccessToken];
}

- (void)showModalLogin {
    UIWindow *mainWindow = (((SPiDHybridAppDelegate *) [UIApplication sharedApplication].delegate).window);

    // Create a modal login view
    self.modalView = [[ModalLoginView alloc] initWithFrame:CGRectMake(0, 0, mainWindow.frame.size.width, mainWindow.frame.size.height)];

    // Bind action to login button
    [self.modalView.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];

    // Add and show the modal view
    [mainWindow addSubview:self.modalView];
    [self.modalView showModal];
}

- (void)dismissModalLogin:(id)sender {
    CGRect start = self.loginView.frame;
    UIWindow *mainWindow = (((SPiDHybridAppDelegate *) [UIApplication sharedApplication].delegate).window);
    CGRect end = CGRectMake(start.origin.x, mainWindow.frame.size.height, start.size.width, start.size.height);

    [UIView animateWithDuration:0.35 animations:^{
        self.modalView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        self.loginView.frame = end;
    }                completion:^(BOOL finished) {
        [self.modalView removeFromSuperview];
        self.modalView = nil;
    }];
}

// UIWebView delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [NSString stringWithFormat:@"%@://%@%@", [[request URL] scheme], [[request URL] host], [[request URL] path]];

    // These are the two urls we need to catch
    NSString *serverUrl = [SPiDClient sharedInstance].serverURL.absoluteString;
    NSString *serverLoginUrl = [NSString stringWithFormat:@"%@/auth/login", serverUrl];
    NSString *serverLogoutUrl = [NSString stringWithFormat:@"%@/logout", serverUrl];
    NSString *serverAccountSummaryUrl = [NSString stringWithFormat:@"%@/account/summary", serverUrl];

    SPiDDebugLog(@"Loading: %@?%@", url, [[request URL] query]);

    if ([url isEqualToString:serverLoginUrl]) {
        SPiDDebugLog(@"Intercepted SPiD login page");
        [self showLoginButtonPressed:nil];
        return NO;
    } else if ([url isEqualToString:serverLogoutUrl]) {
        SPiDDebugLog(@"Intercepted SPiD logout page");
        [self logout:nil];
        return NO;
    } else if ([url hasPrefix:serverAccountSummaryUrl]) { // This is the page we get redirected to when the login is completed (the example uses redirect uri back to spid)
        self.loginBarButton.title = @"Logout";
        [self.loginBarButton setAction:@selector(logout:)];
        [self.loadingSpinner dismissAlert];
    }

    return YES;
}

@end
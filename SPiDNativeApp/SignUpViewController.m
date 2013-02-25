//
//  LoginViewController
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/21/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SignUpViewController.h"
#import "SPiDNativeAppDelegate.h"
#import "SPiDUser.h"
#import "TermsViewController.h"
#import "SPiDError.h"

@implementation SignUpViewController

@synthesize signUpTableView = _signUpTableView;
@synthesize emailTextField = _emailTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize signUpButton = _signUpButton;
@synthesize loginButton = _loginButton;
@synthesize alertView = _alertView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SPiD sign up";
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [UIColor colorWithRed:238 / 255.0 green:238 / 255.0 blue:238 / 255.0 alpha:1];

    // Dismiss keyboard when user taps the view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [[self view] addGestureRecognizer:tapGestureRecognizer];

    // Put everything in a scrollview to get the bouncy effect
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.alwaysBounceVertical = YES;

    CGFloat horizontalCenter = self.view.frame.size.width / 2;
    // Login/password tableview
    self.signUpTableView = [[UITableView alloc] initWithFrame:CGRectMake(horizontalCenter - 160, 0, 320, 110) style:UITableViewStyleGrouped];
    self.signUpTableView.dataSource = self;
    self.signUpTableView.backgroundView = nil;
    self.signUpTableView.scrollEnabled = NO;
    [scrollView addSubview:self.signUpTableView];

    self.signUpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.signUpButton.frame = CGRectMake(horizontalCenter - 145, 120, 290, 43);
    self.signUpButton.titleLabel.shadowColor = [UIColor blackColor];
    self.signUpButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.signUpButton setTitle:@"Register" forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"red_button.png"] forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(signUpToSPiD:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.signUpButton];

    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.loginButton.frame = CGRectMake(horizontalCenter - 145, 170, 290, 43);
    self.loginButton.titleLabel.shadowColor = [UIColor blackColor];
    self.loginButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.loginButton setTitle:@"Already have an account? Log in!" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"red_button.png"] forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(switchToLogin:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.loginButton];

    UILabel *serviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalCenter - 130, 220, 260, 20)];
    serviceLabel.textColor = [UIColor darkGrayColor];
    serviceLabel.backgroundColor = [UIColor clearColor];
    serviceLabel.font = [UIFont systemFontOfSize:12];
    serviceLabel.textAlignment = NSTextAlignmentCenter;
    serviceLabel.text = @"By using this service you are agreeing the";
    [scrollView addSubview:serviceLabel];

    UILabel *termsLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalCenter - 40, 235, 80, 20)];
    termsLabel.textColor = [UIColor darkGrayColor];
    termsLabel.backgroundColor = [UIColor clearColor];
    termsLabel.font = [UIFont boldSystemFontOfSize:12];
    termsLabel.textAlignment = (NSTextAlignment) NSTextAlignmentCenter;
    termsLabel.text = @"Terms of use";

    // Open webview when "Terms of use" is clicked
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTermsOfUse:)];
    [termsLabel setUserInteractionEnabled:YES];
    [termsLabel addGestureRecognizer:gesture];
    [scrollView addSubview:termsLabel];


    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:scrollView];
}

- (void)showTermsOfUse:(id)showTermsOfUse {
    TermsViewController *termsViewController = [[TermsViewController alloc] init];
    [self.navigationController pushViewController:termsViewController animated:YES];
}

- (IBAction)dismissKeyboard:(id)sender {
    [[self view] endEditing:YES];
}

- (void)signUpToSPiD:(id)signUpToSPiD {
    NSString *email = [self.emailTextField text];
    NSString *password = [self.passwordTextField text];
    if ([email length] == 0) {
        [(SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate] showAlertViewWithTitle:@"Email is empty"];
    } else if ([password length] == 0) {
        [(SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate] showAlertViewWithTitle:@"Password is empty"];
    } else {
        [self createSPiDAccountWithEmail:email andPassword:password];
    };
}

- (void)createSPiDAccountWithEmail:(NSString *)email andPassword:(NSString *)password {
    [(SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate] showActivityIndicatorAlert:@"Creating SPiD account\nPlease Wait..."];
    [SPiDUser createAccountWithEmail:email password:password completionHandler:^(SPiDError *error) {
        [(SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate] dismissAlertView];
        if (error) {
            if ([error.descriptions objectForKey:@"blocked"]) {
                [(SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate] showAlertViewWithTitle:[error.descriptions objectForKey:@"blocked"]];
            } else if ([error.descriptions objectForKey:@"exists"]) {
                [(SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate] showAlertViewWithTitle:[error.descriptions objectForKey:@"exists"]];
            } else if ([error.descriptions objectForKey:@"email"]) {
                [(SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate] showAlertViewWithTitle:[error.descriptions objectForKey:@"email"]];
            } else if ([error.descriptions objectForKey:@"password"]) {
                [(SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate] showAlertViewWithTitle:[error.descriptions objectForKey:@"password"]];
            } else {
                NSString *errorString = nil;
                NSArray *values = [error.descriptions allValues];
                if ([values count] != 0)
                    errorString = [values objectAtIndex:0];
                [(SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate] showAlertViewWithTitle:errorString];
            }
        } else {
            //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
            [(SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate] showAlertViewWithTitle:@"Successfully created SPiD account\nCheck your email for verification"];
            [self switchToLogin:nil];
        }
    }];
}

- (IBAction)switchToLogin:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// UITextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.emailTextField]) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self signUpToSPiD:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.emailTextField]) {
        textField.returnKeyType = UIReturnKeyNext;
    } else {
        textField.returnKeyType = UIReturnKeyDone;
    }
}

// UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8.f, 6.f, 90.f, 31.0f)];
    [label setFont:[UIFont boldSystemFontOfSize:15]];

    switch (indexPath.row) {
        case 0:
            label.text = @"Email";
            self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(95.f, 6.f, 200.f, 31.f)];
            self.emailTextField.textAlignment = NSTextAlignmentLeft;
            self.emailTextField.font = [UIFont systemFontOfSize:15];
            self.emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.emailTextField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.emailTextField];
            break;
        case 1:
            label.text = @"Password";
            self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(95.f, 6.f, 200.f, 31.f)];
            self.passwordTextField.textAlignment = NSTextAlignmentLeft;
            self.passwordTextField.font = [UIFont systemFontOfSize:15];
            self.passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.passwordTextField.secureTextEntry = YES;
            self.passwordTextField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:self.passwordTextField];
            break;
        default:
            break;
    }
    return cell;
}

@end
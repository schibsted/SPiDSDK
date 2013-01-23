//
//  MainViewController
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/21/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "MainViewController.h"
#import "SPiDNativeAppDelegate.h"

@implementation MainViewController {

}

@synthesize loginTableView;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize loginButton;
@synthesize alertView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"SPiD"];
    [self view].backgroundColor = [UIColor colorWithRed:238 / 255.0 green:238 / 255.0 blue:238 / 255.0 alpha:1];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [[self view] addGestureRecognizer:tapGestureRecognizer];

    loginTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 110) style:UITableViewStyleGrouped];
    loginTableView.dataSource = self;
    [loginTableView setBackgroundView:nil];
    [self.view addSubview:loginTableView];

    loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];//UIButtonTypeCustom
    loginButton.frame = CGRectMake(35, 130, 250, 43);
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"red_button.png"] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginToSPiD:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (IBAction)dismissKeyboard:(id)sender {
    [[self view] endEditing:YES];
}

- (IBAction)loginToSPiD:(id)sender {
    NSString *username = [usernameTextField text];
    NSString *password = [passwordTextField text];
    if ([username length] == 0) {
        alertView = [[UIAlertView alloc]
                initWithTitle:@"Username is empty"
                      message:nil delegate:nil cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        [alertView show];
    } else if ([password length] == 0) {
        alertView = [[UIAlertView alloc]
                initWithTitle:@"Password is empty"
                      message:nil delegate:nil cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        [alertView show];
    } else {
        [self showLoginAlert:@"Logging in using SPiD\nPlease Wait..."];
        SPiDNativeAppDelegate *appDelegate = (SPiDNativeAppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate loginWithUsername:username andPassword:password];
    }
}

- (void)showLoginAlert:(NSString *)loginString {
    alertView = [[UIAlertView alloc] initWithTitle:loginString
                                           message:nil delegate:self
                                 cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView show];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(alertView.bounds.size.width / 2, alertView.bounds.size.height - 50);
    [indicator startAnimating];
    [alertView addSubview:indicator];
}

- (void)dismissLoginAlert {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

// UITextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:usernameTextField]) {
        [textField resignFirstResponder];
        [passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self loginToSPiD:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:usernameTextField]) {
        textField.returnKeyType = UIReturnKeyNext;
    } else {
        textField.returnKeyType = UIReturnKeyDone;
    }
}

// UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.backgroundColor = [UIColor whiteColor];

    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8.f, 6.f, 90.f, 31.0f)];
    [label setFont:[UIFont boldSystemFontOfSize:15]];

    switch (indexPath.row) {
        case 0:
            label.text = @"Username";
            usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(95.f, 6.f, 200.f, 31.f)];
            usernameTextField.textAlignment = NSTextAlignmentLeft;
            usernameTextField.font = [UIFont systemFontOfSize:15];
            usernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            usernameTextField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:usernameTextField];
            break;
        case 1:
            label.text = @"Password";
            passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(95.f, 6.f, 200.f, 31.f)];
            passwordTextField.textAlignment = NSTextAlignmentLeft;
            passwordTextField.font = [UIFont systemFontOfSize:15];
            passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            passwordTextField.secureTextEntry = YES;
            passwordTextField.delegate = self;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:passwordTextField];

            break;
        default:
            break;
    }
    return cell;
}

@end
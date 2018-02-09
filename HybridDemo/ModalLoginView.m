//
//  ModalLoginView
//  SPiDHybridApp
//
//  Copyright (c) 2013 Schibsted Payment. All rights reserved.
//

#import "ModalLoginView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ModalLoginView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];

    CGFloat elementWidth = 260.0f;
    CGFloat elementOffset = 10.0f;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissModal:)];
    [self addGestureRecognizer:tapGestureRecognizer];

    // TODO: convert this to absolute coords instead
    CGFloat loginViewWidth = 280;
    CGFloat loginViewHeight = 310;

    // Create login view
    self.loginView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - loginViewWidth) / 2, (self.frame.size.height - loginViewHeight) / 2, loginViewWidth, loginViewHeight)];
    self.loginView.backgroundColor = [UIColor whiteColor];
    self.loginView.layer.cornerRadius = 8;
    self.loginView.alpha = 1.0;
    self.loginView.clipsToBounds = YES;

    // Setup dismiss keyboard gesture
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.loginView addGestureRecognizer:tapGestureRecognizer1];

    // Add SPiD image
    UIImage *spidImage = [UIImage imageNamed:@"SPiDLogoTest.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:spidImage];
    imageView.backgroundColor = [UIColor colorWithRed:0 green:80.0f / 255.0f blue:145.0f / 255.0f alpha:1];
    imageView.frame = CGRectMake(0, 0, loginViewWidth, spidImage.size.height);
    imageView.contentMode = UIViewContentModeCenter;
    [self.loginView addSubview:imageView];

    // Add table view
    CGRect loginTableViewFrame = CGRectMake((loginViewWidth - elementWidth) / 2, imageView.frame.origin.y + imageView.frame.size.height + elementOffset, elementWidth, 0);
    self.loginTableView = [[UITableView alloc] initWithFrame:loginTableViewFrame style:UITableViewStylePlain];
    self.loginTableView.dataSource = self;
    self.loginTableView.scrollEnabled = NO;
    self.loginTableView.layer.cornerRadius = 10;
    self.loginTableView.layer.borderWidth = 1;
    self.loginTableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [self.loginView addSubview:self.loginTableView];

    // Force redraw and calculate new height of UITableView
    [self.loginTableView layoutIfNeeded];
    loginTableViewFrame = self.loginTableView.frame;
    loginTableViewFrame.size.height = self.loginTableView.contentSize.height;
    self.loginTableView.frame = loginTableViewFrame;

    // Add login button
    CGRect loginButtonFrame = CGRectMake((loginViewWidth - elementWidth) / 2, loginTableViewFrame.origin.y + loginTableViewFrame.size.height + elementOffset, elementWidth, 44);
    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.loginButton.frame = loginButtonFrame;
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton layoutIfNeeded];
    [self.loginView addSubview:self.loginButton];

    // Add cancel button
    CGRect cancelButtonFrame = CGRectMake((loginViewWidth - elementWidth) / 2, loginButtonFrame.origin.y + loginButtonFrame.size.height + elementOffset / 2, elementWidth, 44);
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.cancelButton.frame = cancelButtonFrame;
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(dismissModal:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView addSubview:self.cancelButton];

    // Add service label
    CGRect serviceLabelFrame = CGRectMake((loginViewWidth - elementWidth) / 2, loginViewHeight - 40, elementWidth, 20);
    UILabel *serviceLabel = [[UILabel alloc] initWithFrame:serviceLabelFrame];
    serviceLabel.textColor = [UIColor darkGrayColor];
    serviceLabel.backgroundColor = [UIColor clearColor];
    serviceLabel.font = [UIFont systemFontOfSize:12];
    serviceLabel.textAlignment = NSTextAlignmentCenter;
    serviceLabel.text = @"By using this service you are agreeing the";
    [self.loginView addSubview:serviceLabel];

    // Add terms label
    CGRect termsLabelFrame = CGRectMake((loginViewWidth - elementWidth) / 2, serviceLabelFrame.origin.y + serviceLabelFrame.size.height - 5, elementWidth, 20);
    UILabel *termsLabel = [[UILabel alloc] initWithFrame:termsLabelFrame];
    termsLabel.textColor = [UIColor darkGrayColor];
    termsLabel.backgroundColor = [UIColor clearColor];
    termsLabel.font = [UIFont boldSystemFontOfSize:12];
    termsLabel.textAlignment = NSTextAlignmentCenter;
    termsLabel.text = @"Terms of use";
    [self.loginView addSubview:termsLabel];

    // Add login view
    [self addSubview:self.loginView];
}

- (void)showModal {
    [UIView animateWithDuration:0.35 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        //self.loginView.frame = end;
    }                completion:^(BOOL finished) {
    }];
}

- (void)dismissModal:(id)dismissModal {
    [UIView animateWithDuration:0.35 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
    }                completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dismissKeyboard:(id)dismissKeyboard {
    [self endEditing:YES];
}

// UITableView methods
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

    switch (indexPath.row) {
        case 0:
            self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.f, 6.f, 250.f, 31.f)];
            self.emailTextField.textAlignment = NSTextAlignmentLeft;
            self.emailTextField.font = [UIFont systemFontOfSize:15];
            self.emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.emailTextField.placeholder = @"Email";
            [cell.contentView addSubview:self.emailTextField];
            break;
        case 1:
            self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.f, 6.f, 250.f, 31.f)];
            self.passwordTextField.textAlignment = NSTextAlignmentLeft;
            self.passwordTextField.font = [UIFont systemFontOfSize:15];
            self.passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.passwordTextField.secureTextEntry = YES;
            self.passwordTextField.placeholder = @"Password";
            [cell.contentView addSubview:self.passwordTextField];
            break;
        default:
            break;
    }
    return cell;
}

@end
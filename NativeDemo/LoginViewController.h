//
//  LoginViewController
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/21/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface LoginViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource>

@property(strong, nonatomic) UITableView *loginTableView;
@property(strong, nonatomic) UITextField *emailTextField;
@property(strong, nonatomic) UITextField *passwordTextField;
@property(strong, nonatomic) UIButton *loginButton;
@property(strong, nonatomic) UIButton *signUpButton;
@property(strong, nonatomic) UIButton *lostPasswordButton;
@property(strong, nonatomic) UIAlertView *alertView;

@end

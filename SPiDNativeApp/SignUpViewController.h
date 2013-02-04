//
//  LoginViewController
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/21/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignUpViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource>

@property(strong, nonatomic) UITableView *signUpTableView;
@property(strong, nonatomic) UITextField *emailTextField;
@property(strong, nonatomic) UITextField *passwordTextField;
@property(strong, nonatomic) UIButton *signUpButton;
@property(strong, nonatomic) UIButton *loginButton;
@property(strong, nonatomic) UIAlertView *alertView;

@end
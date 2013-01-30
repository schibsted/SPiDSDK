//
//  MainViewController
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/21/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource>

@property(strong, nonatomic) UITableView *loginTableView;
@property(strong, nonatomic) UITextField *usernameTextField;
@property(strong, nonatomic) UITextField *passwordTextField;
@property(strong, nonatomic) UIButton *loginButton;
@property(strong, nonatomic) UIButton *signupButton;
@property(strong, nonatomic) UIAlertView *alertView;

- (void)dismissLoginAlert;

@end
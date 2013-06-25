//
//  ModalLoginView
//  SPiDHybridApp
//
//  Copyright (c) 2013 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModalLoginView : UIView <UITableViewDataSource>
@property(nonatomic, strong) UIButton *loginButton;

@property(nonatomic, strong) UIView *loginView;

@property(nonatomic, strong) UITextField *emailTextField;

@property(nonatomic, strong) UITextField *passwordTextField;

@property(nonatomic, strong) UIButton *cancelButton;

@property(nonatomic, strong) UITableView *loginTableView;

- (void)showModal;
@end
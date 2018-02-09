//
//  MainViewController
//  SPiDHybridApp
//
//  Copyright (c) 2013 Schibsted Payment. All rights reserved.
//

@import Foundation;
@import UIKit;

@class ModalLoginView;
@class LoadingAlertView;

@interface MainViewController : UIViewController <UIWebViewDelegate>

@property(strong, nonatomic) UIButton *showLoginButton;
@property(strong, nonatomic) UIWebView *webView;
@property(strong, nonatomic) ModalLoginView *modalView;
@property(strong, nonatomic) UIView *loginView;
@property(nonatomic, strong) UIBarButtonItem *loginBarButton;
@property(nonatomic, strong) LoadingAlertView *loadingSpinner;
@property(nonatomic, strong) UIAlertView *alertView;

@end

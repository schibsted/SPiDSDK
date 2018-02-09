//
//  AppDelegate.h
//  SPiDNativeApp
//
//  Created by Mikael Lindström on 1/21/13.
//  Copyright (c) 2013 Mikael Lindström. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface SPiDNativeAppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) UINavigationController *rootNavigationController;
@property(strong, nonatomic) UINavigationController *authNavigationController;
@property(strong, nonatomic) UIAlertController *alertController;

- (void)presentLoginViewAnimated:(BOOL)animated;

- (void)showAlertViewWithTitle:(NSString *)title fromController:(UIViewController *)controller completionHandler:(void (^)(void))completionHandler;

- (void)showActivityIndicatorAlert:(NSString *)title fromController:(UIViewController *)controller completionHandler:(void (^)(void))completionHandler;

- (void)dismissAlertViewFromController:(UIViewController *)controller completionHandler:(void (^)(void))completionHandler;

@end

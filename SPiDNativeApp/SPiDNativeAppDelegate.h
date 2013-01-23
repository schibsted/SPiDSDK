//
//  AppDelegate.h
//  SPiDNativeApp
//
//  Created by Mikael Lindström on 1/21/13.
//  Copyright (c) 2013 Mikael Lindström. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface SPiDNativeAppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) UINavigationController *navigationController;
@property(strong, nonatomic) MainViewController *mainView;

- (void)loginWithUsername:(NSString *)string andPassword:(NSString *)password;
@end

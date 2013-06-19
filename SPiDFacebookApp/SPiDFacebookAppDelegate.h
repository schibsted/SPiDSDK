//
//  SPiDFacebookAppDelegate.h
//  SPiDFacebookApp
//
//  Created by Mikael Lindström on 1/21/13.
//  Copyright (c) 2013 Mikael Lindström. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const FBSessionStateChangedNotification;

@interface SPiDFacebookAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property(strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) UINavigationController *rootNavigationController;
@property(strong, nonatomic) UINavigationController *facebookNavigationController;
@property(strong, nonatomic) UIAlertView *alertView;

- (void)presentFacebookViewAnimated:(BOOL)b;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

- (void)showActivityIndicatorAlert:(NSString *)title;

- (void)showAlertViewWithTitle:(NSString *)title;

- (void)dismissAlertView;


@end

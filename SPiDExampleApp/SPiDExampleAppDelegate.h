//
//  SPiDHybridAppDelegate.h
//  SPiDExampleApp
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPiDLoginViewController.h"
#import "SPiDMainViewController.h"

@interface SPiDExampleAppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) IBOutlet UIWindow *window;
@property(strong, nonatomic) IBOutlet UINavigationController *navigationController;
@property(strong, nonatomic) IBOutlet UIViewController *loginView;
@property(strong, nonatomic) IBOutlet UIViewController *mainView;
@property(nonatomic) BOOL useWebView;

@end

//
//  AppDelegate.m
//  SPiDNativeApp
//
//  Created by Mikael Lindström on 1/21/13.
//  Copyright (c) 2013 Mikael Lindström. All rights reserved.
//

#import "SPiDNativeAppDelegate.h"

@implementation SPiDNativeAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize mainView = _mainView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    [self setMainView:[[MainViewController alloc] init]];
    [self setNavigationController:[[UINavigationController alloc] initWithRootViewController:[self mainView]]];
    [[self window] setRootViewController:[self navigationController]];

    [self.window makeKeyAndVisible];
    return YES;
}

@end

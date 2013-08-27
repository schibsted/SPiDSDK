//
//  SPiDMainViewController.m
//  SPiDSDK
//
//  Copyright (c) 2013 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SPiDClient.h"
#include "SPiDRequest.h"


@interface SPiDMainViewController : UIViewController

@property(strong, nonatomic) IBOutlet UILabel *userLabel;
@property(strong, nonatomic) IBOutlet UILabel *tokenLabel;
@property(strong, nonatomic) IBOutlet UILabel *oneTimeCodeLabel;

@end
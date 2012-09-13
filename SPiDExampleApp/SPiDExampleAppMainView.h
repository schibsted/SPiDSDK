//
//  SPiDExampleAppMainView.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDAPI.h"
#import "SPiDClient.h"

@interface SPiDExampleAppMainView : UIViewController <UINavigationControllerDelegate>

@property (strong, nonatomic) SPiDAPI *api;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *meButton;

- (IBAction)loginToSPiDClicked:(id)sender;
- (IBAction)meButtonClicked:(id)sender;

@end

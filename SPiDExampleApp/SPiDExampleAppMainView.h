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

- (IBAction)loginByRedirect:(id)sender;

- (IBAction)loginByWebView:(id)sender;

- (IBAction)loginByNative:(id)sender;


@end

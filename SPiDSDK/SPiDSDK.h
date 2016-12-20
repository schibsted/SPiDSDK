//
//  SPiD.h
//  SPiD
//
//  Created by Audun Kjelstrup on 04/05/16.
//  Copyright © 2016 Mikael Lindström. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for SPiD.
FOUNDATION_EXPORT double SPiDVersionNumber;

//! Project version string for SPiD.
FOUNDATION_EXPORT const unsigned char SPiDVersionString[];

// In this header, you should import all the public headers of your framework.

#import "NSError+SPiD.h"
#import "SPiDAccessToken.h"
#import "SPiDClient.h"
#import "SPiDJwt.h"
#import "SPiDKeychainWrapper.h"
#import "SPiDRequest.h"
#import "SPiDResponse.h"
#import "SPiDStatus.h"
#import "SPiDTokenRequest.h"
#import "SPiDUser.h"
#import "SPiDUtils.h"
#import "SPiDAgreements.h"

#if TARGET_OS_IOS
    #import "SPiDWebView.h"
#endif

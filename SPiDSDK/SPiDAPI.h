//
//  SPiDAPI.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/12/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"

@interface SPiDAPI : NSObject {
@private GTMOAuth2Authentication *authentication;

}

- (id)initWithGTMOauth2Authentication:(GTMOAuth2Authentication *)gtmOath2Authentication;

- (UIViewController *)authorize;

- (void)doAnAuthenticatedAPIFetch;
//- (void)getToken;

@end

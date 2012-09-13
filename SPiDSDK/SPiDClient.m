//
//  SPiDClient.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDClient.h"

@implementation SPiDClient

@synthesize clientID = _clientID;
@synthesize clientSecret = _clientSecret;
@synthesize redirectURL = _redirectURL;

- (id)initWithClientID:(NSString *)clientID
       andClientSecret:(NSString *)clientSecret
        andRedirectURL:(NSURL *)redirectURL {
    if (self = [super init]) {
        self.clientID = clientID;
        self.clientSecret = clientSecret;
        self.redirectURL = redirectURL;
    }
    return self;
}

@end

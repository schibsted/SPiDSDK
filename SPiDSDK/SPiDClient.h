//
//  SPiDClient.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPiDClient : NSObject

@property(strong, nonatomic) NSString *clientID;
@property(strong, nonatomic) NSString *clientSecret;
@property(strong, nonatomic) NSURL *redirectURL;

- (id)initWithClientID:(NSString *)clientID andClientSecret:(NSString *)clientSecret andRedirectURL:(NSURL *)redirectURL;

@end

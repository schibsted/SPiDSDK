//
//  SPiDAccessToken.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/25/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPiDAccessToken : NSObject

// TODO: Should we have scope?
@property(strong, nonatomic) NSString *accessToken;
@property(strong, nonatomic) NSDate *expiresAt;
@property(strong, nonatomic) NSString *refreshToken;

- (id)initWithAccessToken:(NSString *)accessToken andExpiresAt:(NSDate *)expiresAt andRefreshToken:(NSString *)refreshToken;

- (id)initWithDictionary:(NSDictionary *)dictionary;


@end
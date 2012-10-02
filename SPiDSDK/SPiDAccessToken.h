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
@property(strong, nonatomic) NSString *userID;
@property(strong, nonatomic) NSString *accessToken;
@property(strong, nonatomic) NSDate *expiresAt;
@property(strong, nonatomic) NSString *refreshToken;

- (id)initWithUserID:(NSString *)userID andAccessToken:(NSString *)accessToken andExpiresAt:(NSDate *)expiresAt andRefreshToken:(NSString *)refreshToken;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (BOOL)hasTokenExpired;

@end
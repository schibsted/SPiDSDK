//
// Created by mikaellindstrom on 9/25/12.
//
// To change the template use AppCode | Preferences | File Templates.
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
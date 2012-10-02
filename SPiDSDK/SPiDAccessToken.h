//
//  SPiDAccessToken.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/25/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class description....
 */

@interface SPiDAccessToken : NSObject

// TODO: Should we have scope?
/** User ID for the current client */
@property(strong, nonatomic) NSString *userID;

/** The OAuth 2.0 access token */
@property(strong, nonatomic) NSString *accessToken;

/** Expiry date for the access token */
@property(strong, nonatomic) NSDate *expiresAt;

/** Refresh token used for refreshing the access token  */
@property(strong, nonatomic) NSString *refreshToken;

/** Initializes the AccessToken from the parameters

 @param userID
 @param accessToken
 @param expiresAt
 @param refreshToken
 @return SPiDAccessToken
 */
- (id)initWithUserID:(NSString *)userID andAccessToken:(NSString *)accessToken andExpiresAt:(NSDate *)expiresAt andRefreshToken:(NSString *)refreshToken;

/** Initializes the AccessToken from a dictionary

 @param dictionary
 @return SPiDAccessToken
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

/** Decodes the access token

 @param decoder
 @return SPiDAccessToken
 */
- (id)initWithCoder:(NSCoder *)decoder;

/** Encodes the access token

 @param coder
 */
- (void)encodeWithCoder:(NSCoder *)coder;

/** Checks if the access token has expired

@Return Returns YES if access token has expired
*/
- (BOOL)hasTokenExpired;

@end
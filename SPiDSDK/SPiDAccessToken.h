//
//  SPiDAccessToken.h
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Contains a access token that can be saved to the keychain */

@interface SPiDAccessToken : NSObject <NSCoding>

///---------------------------------------------------------------------------------------
/// @name Public properties
///---------------------------------------------------------------------------------------

// Note: We have not included scope since it is not used, might have to be added later
/** User ID for the current client */
@property(strong, nonatomic) NSString *userID;

/** The OAuth 2.0 access token */
@property(strong, nonatomic) NSString *accessToken;

/** Expiry date for the access token */
@property(strong, nonatomic) NSDate *expiresAt;

/** Refresh token used for refreshing the access token  */
@property(strong, nonatomic) NSString *refreshToken;

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** Initializes the AccessToken from the parameters

 @param userID Current user ID
 @param accessToken Access token
 @param expiresAt Access token expires at date
 @param refreshToken Refresh token
 @return SPiDAccessToken
 */
- (id)initWithUserID:(NSString *)userID accessToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt refreshToken:(NSString *)refreshToken;

/** Initializes the AccessToken from a dictionary

 @param dictionary Received data from SPiD
 @return SPiDAccessToken
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

/** Decodes the access token

 @param decoder Decoder to use
 @return SPiDAccessToken
 */
- (id)initWithCoder:(NSCoder *)decoder;

/** Encodes the access token

 @param coder Encoder to use
 */
- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)stringFromObject:(id)obj;

/** Checks if the access token has expired

@Return Returns YES if access token has expired
*/
- (BOOL)hasExpired;

/** Checks if the access token is a client token

@Return Returns YES if the access token is a client token
*/
- (BOOL)isClientToken;

@end
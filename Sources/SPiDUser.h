//
//  SPiDUser
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Handles user creation and validation against SPiD.

 This requires access to the /signup endpoint with client credentials
*/

@interface SPiDUser : NSObject

///---------------------------------------------------------------------------------------
/// @name Public Methods
///---------------------------------------------------------------------------------------

/** Creates a new SPiD user account

 @param email The email
 @param password The password
 @param completionHandler Called after user has been created
*/
+ (void)createAccountWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSError * __nullable))completionHandler;

/** Creates a new SPiD user account using a Facebook user

 @param appId Facebook app id
 @param facebookToken Facebook access token
 @param expirationDate Facebook access token expiration date
 @param completionHandler Called after user has been created
*/
+ (void)createAccountWithFacebookAppID:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate completionHandler:(void (^)(NSError * __nullable))completionHandler;

/** Attaches a Facebook user to the currently logged in user

 @param appId Facebook app id
 @param facebookToken Facebook access token
 @param expirationDate Facebook access token expiration date
 @param completionHandler Called after user has been created
*/
+ (void)attachAccountWithFacebookAppID:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate completionHandler:(void (^)(NSError * __nullable))completionHandler;

/** Validates user credentials

 @param email The email to validate
 @param password The password to validate
 @return Validation error if found, otherwise nil
*/
- (NSError * __nullable)validateEmail:(NSString *)email password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END

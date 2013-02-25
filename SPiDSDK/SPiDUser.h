//
//  SPiDUser
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPiDError;

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
+ (void)createAccountWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(SPiDError *))completionHandler;

/** Generates user credentials post data

 @param email The email
 @param password The password
 @return Dictionary with the post data
*/
- (NSDictionary *)userPostDataWithEmail:(NSString *)email password:(NSString *)password;

/** Validates user credentials

 @param email The email to validate
 @param password The password to validate
 @return Validation error if found, otherwise nil
*/
- (SPiDError *)validateEmail:(NSString *)email password:(NSString *)password;


@end
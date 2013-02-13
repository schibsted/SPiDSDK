//
//  SPiDKeychainWrapper.h
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDAccessToken.h"

/** `SPiDKeychainWrapper` is a wrapper used to simplfy keychain access.
 It is used by the `SPiDClient` for all keychain operations.
*/

@interface SPiDKeychainWrapper : NSObject

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** Get access token from keychain
 Tries to load the access token from the keychain

 @param identifier Unique identification for this keychain item
 @return Access token if available otherwise nil
 */
+ (SPiDAccessToken *)getAccessTokenFromKeychainForIdentifier:(NSString *)identifier;

/** Saves access token to keychain
 Tries to save the access token to the keychain

 @param accessToken Access token to save
 @param identifier Unique identification for this keychain item
 @return Access token if available otherwise nil
 */
+ (BOOL)storeInKeychainAccessTokenWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier;

/** Update access token in keychain
 Tries to update the access token in the keychain

 @param accessToken Access token to save
 @param identifier Unique identification for this keychain item
 @return YES if successful otherwise NO
 */
+ (BOOL)updateAccessTokenInKeychainWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier;

/** Remove access token from keychain
 Tries to remove the access token from the keychain

 @param identifier Unique identification for this keychain item
 */
+ (void)removeAccessTokenFromKeychainForIdentifier:(NSString *)identifier;

@end
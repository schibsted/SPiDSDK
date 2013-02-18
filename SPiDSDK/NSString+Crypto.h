//
//  NSString+Crypto
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

/** Adds HMAC SHA256 generations to `NSString` */

@interface NSString (Crypto)

/** Generates a HMAC SHA256 signature for a string

 @param key Encoding key
 @return The signature in hex
 */
- (NSString *)hmacSHA256withKey:(NSString *)key;

@end
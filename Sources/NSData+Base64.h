//
//  NSData+Base64
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Adds Base64 encoding/decoding to `NSData` */

@interface NSData (Base64)

/** Encodes data to a Base64 string

 @return Encoded string
 */
- (NSString *)sp_base64EncodedString;

- (NSString *)sp_base64EncodedUrlSafeString;

@end
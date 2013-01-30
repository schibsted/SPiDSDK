//
//  NSString+Crypto
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/28/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

@interface NSString (Crypto)

- (NSString *)hmacSHA256withKey:(NSString *)key;

@end
//
//  NSData+Base64
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/21/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

+ (NSData *)decodeBase64String:(NSString *)base64String;

- (NSString *)base64EncodedString;

@end
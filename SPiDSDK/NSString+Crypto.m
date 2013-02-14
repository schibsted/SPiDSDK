//
//  NSString+Crypto
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "NSString+Crypto.h"

@implementation NSString (Crypto)

- (NSString *)hmacSHA256withKey:(NSString *)key {
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, (void *) cKey, strlen(cKey), (void *) cData, strlen(cData), cHMAC);

    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < sizeof cHMAC; i++) {
        [result appendFormat:@"%02hhx", cHMAC[i]];
    }
    return result;
}

@end
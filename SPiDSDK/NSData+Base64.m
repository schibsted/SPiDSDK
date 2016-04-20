//
//  NSData+Base64
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "NSData+Base64.h"

@implementation NSData (Base64)

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


- (NSString *)base64EncodedString {
    const unsigned char *objRawData = [self bytes];
    char *objPointer;
    char *strResult;

    NSUInteger intLength = [self length];
    if (intLength == 0) return nil;

    strResult = (char *) calloc((size_t) ((((intLength + 2) / 3) * 4) + 1), sizeof(char));
    objPointer = strResult;

    while (intLength > 2) {
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
        *objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
        *objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];

        objRawData += 3;
        intLength -= 3;
    }

    if (intLength != 0) {
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        if (intLength > 1) {
            *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
            *objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
            *objPointer++ = '=';
        } else {
            *objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
            *objPointer++ = '=';
            *objPointer++ = '=';
        }
    }

    // Terminate the string-based result
    *objPointer = '\0';

    NSString *base64String = [NSString stringWithCString:strResult encoding:NSASCIIStringEncoding];
    free(strResult);
    return base64String;
}

- (NSString *)base64EncodedUrlSafeString {
    NSString *urlSafeBase64String = [self base64EncodedString];
    urlSafeBase64String = [urlSafeBase64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    urlSafeBase64String = [urlSafeBase64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    urlSafeBase64String = [urlSafeBase64String stringByReplacingOccurrencesOfString:@"=" withString:@""];
    return urlSafeBase64String;
}

@end

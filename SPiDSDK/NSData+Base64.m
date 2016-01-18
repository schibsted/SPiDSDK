//
//  NSData+Base64
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "NSData+Base64.h"

@implementation NSData (Base64)

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
        -2, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
        -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

+ (NSData *)decodeBase64String:(NSString *)base64String {
    const char *objPointer = [base64String cStringUsingEncoding:NSASCIIStringEncoding];
    size_t intLength = strlen(objPointer);
    int intCurrent;
    int i = 0, j = 0, k;

    unsigned char *objResult = calloc(intLength, sizeof(unsigned char));

    while (((intCurrent = *objPointer++) != '\0') && (intLength-- > 0)) {
        if (intCurrent == '=') {
            if (*objPointer != '=' && ((i % 4) == 1)) {
                // the padding character is invalid
                free(objResult);
                return nil;
            }
            continue;
        }

        intCurrent = _base64DecodingTable[intCurrent];
        if (intCurrent == -1) {
            // skip whitespace
            continue;
        } else if (intCurrent == -2) {
            // invalid character
            free(objResult);
            return nil;
        }

        switch (i % 4) {
            case 0:
                objResult[j] = (unsigned char) (intCurrent << 2);
                break;

            case 1:
                objResult[j++] |= intCurrent >> 4;
                objResult[j] = (unsigned char) ((intCurrent & 0x0f) << 4);
                break;

            case 2:
                objResult[j++] |= intCurrent >> 2;
                objResult[j] = (unsigned char) ((intCurrent & 0x03) << 6);
                break;

            default: //case 3:
                objResult[j++] |= intCurrent;
                break;
        }
        i++;
    }

    k = j;
    if (intCurrent == '=') {
        switch (i % 4) {
            case 1:
                // Invalid state
                free(objResult);
                return nil;

            case 2:
                k++;
                // flow through
            default: //case 3:
                objResult[k] = 0;
        }
    }

    NSData *objData = [NSData dataWithBytesNoCopy:objResult length:(NSUInteger) j freeWhenDone:YES];   
    return objData;
}

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

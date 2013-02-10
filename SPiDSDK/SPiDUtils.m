//
//  SPiDUtils.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/13/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDUtils.h"

@implementation SPiDUtils

+ (BOOL)validateEmail:(NSString *)email {
    NSString *emailRegex =
            @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
                    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
                    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
                    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
                    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
                    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
                    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (NSString *)encodedHttpQueryForDictionary:(NSDictionary *)dictionary {
    NSString *body = @"";
    for (NSString *key in dictionary) {
        if ([body length] > 0) {
            body = [body stringByAppendingFormat:@"&%@=%@", [SPiDUtils urlEncodeString:key], [SPiDUtils urlEncodeString:[dictionary objectForKey:key]]];
        } else {
            body = [body stringByAppendingFormat:@"?%@=%@", [SPiDUtils urlEncodeString:key], [SPiDUtils urlEncodeString:[dictionary objectForKey:key]]];
        }
    }
    return body;
}

+ (NSString *)encodedHttpBodyForDictionary:(NSDictionary *)dictionary {
    NSString *body = @"";
    for (NSString *key in dictionary) {
        if ([body length] > 0) {
            body = [body stringByAppendingFormat:@"&%@=%@", [SPiDUtils urlEncodeString:key], [SPiDUtils urlEncodeString:[dictionary objectForKey:key]]];
        } else {
            body = [body stringByAppendingFormat:@"%@=%@", [SPiDUtils urlEncodeString:key], [SPiDUtils urlEncodeString:[dictionary objectForKey:key]]];
        }
    }
    return body;
}

+ (NSURL *)urlEncodeString:(NSString *)unescaped {
    NSString *escapedString = (NSString *) CFBridgingRelease((CFTypeRef) CFURLCreateStringByAddingPercentEscapes(
            NULL,
            (__bridge CFStringRef) unescaped,
            NULL,
            (CFStringRef) @"!*'();:@&=+$,/?%#[]",
            kCFStringEncodingUTF8));
    return [NSURL URLWithString:escapedString];
}

+ (NSString *)getUrlParameter:(NSURL *)url forKey:(NSString *)key {
    NSArray *encodedParameterPairs = [[url query] componentsSeparatedByString:@"&"];

    for (NSString *encodedPair in encodedParameterPairs) {
        NSArray *encodedPairElements = [encodedPair componentsSeparatedByString:@"="];
        if (encodedPairElements.count == 2) {
            if ([[encodedPairElements objectAtIndex:0] isEqual:key])
                return [encodedPairElements objectAtIndex:1];
        }
    }
    return nil;
}

@end
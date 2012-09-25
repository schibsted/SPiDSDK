//
//  SPiDUtils.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/13/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDUtils.h"

@implementation SPiDUtils

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
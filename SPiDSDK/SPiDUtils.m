//
// Created by mikaellindstrom on 9/13/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SPiDUtils.h"

@implementation SPiDUtils

/*
+ (NSString *)addParameterToString:(NSString *)string withParameterKey:(NSString *)parameterKey withValue:(NSString *)parameterValue {
    if ([string length] > 0) {
        return [NSString stringWithFormat:@"%@&%@=%@", string, parameterKey, [self urlEncodeString:parameterValue]];
    } else {
        return [NSString stringWithFormat:@"%@=%@", parameterKey, [self urlEncodeString:parameterValue]];
    }
}*/

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
/*
+ (NSURL *)stripQueryFromURL:(NSURL *)url {
    NSString *query = [url query];

    if (!query || ![query length]) {
        return [url copy];
    }
    NSMutableString *urlString = [NSMutableString stringWithString:[url absoluteString]];
    [urlString replaceOccurrencesOfString:[NSString stringWithFormat:@"?%@", [url query]]
                               withString:@""
                                  options:NSBackwardsSearch
                                    range:NSMakeRange(0, [urlString length])];
    return [NSURL URLWithString:urlString];
}*/

@end
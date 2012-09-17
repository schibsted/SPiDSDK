//
// Created by mikaellindstrom on 9/13/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SPiDURL.h"

@implementation SPiDURL

+ (NSString *)addToURL:(NSString *)url parameterKey:(NSString *)parameterKey withValue:(NSString *)parameterValue {
    if ([url rangeOfString:@"?"].location == NSNotFound) {
        url = [NSString stringWithFormat:@"%@?%@=%@", url, parameterKey, [self urlEncodeString:parameterValue]];
    } else {
        url = [NSString stringWithFormat:@"%@&%@=%@", url, parameterKey, [self urlEncodeString:parameterValue]];
    }
    return url;
}

+ (NSURL *)urlEncodeString:(NSString *)unescaped {
    NSLog(@"Got string: %@", unescaped);
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
}

@end
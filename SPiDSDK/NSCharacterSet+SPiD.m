//
//  NSCharacterSet+SPiD.m
//  SPiDSDK
//
//  Created by Audun Kjelstrup on 04/05/16.
//  Copyright © 2016 Mikael Lindström. All rights reserved.
//

#import "NSCharacterSet+SPiD.h"

@implementation NSCharacterSet (SPiD)

+ (NSCharacterSet *)URLQueryPartAllowedCharacterSet {
    NSMutableCharacterSet *URLQueryPartAllowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [URLQueryPartAllowedCharacterSet removeCharactersInString:@"!*'();:@&=+$,/?%#[]"];
    return URLQueryPartAllowedCharacterSet;
}
@end

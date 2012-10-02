//
//  SPiDUtils.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/13/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class description....
 */

@interface SPiDUtils : NSObject

+ (NSURL *)urlEncodeString:(NSString *)unescaped;

+ (NSString *)getUrlParameter:(NSURL *)url forKey:(NSString *)key;

@end
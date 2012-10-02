//
//  SPiDUtils.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/13/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Helper functions
 */

@interface SPiDUtils : NSObject

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** URL encodes the specified string

 @param unescaped String to be encoded
 @return Encoded URL
 */
+ (NSURL *)urlEncodeString:(NSString *)unescaped;

/** Extracts a query parameter from a URL

 @param url URL
 @param key Parameter to be found
 @return Value for the specified key otherwise nil
 */
+ (NSString *)getUrlParameter:(NSURL *)url forKey:(NSString *)key;

@end
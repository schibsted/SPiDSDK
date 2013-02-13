//
//  SPiDUtils.h
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Helper functions for parsing and encoding URL:s
 */

@interface SPiDUtils : NSObject

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

+ (NSString *)encodedHttpQueryForDictionary:(NSDictionary *)dictionary;

+ (NSString *)encodedHttpBodyForDictionary:(NSDictionary *)dictionary;

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

// Based on RFC 2822
+ (BOOL)validateEmail:(NSString *)email;


@end
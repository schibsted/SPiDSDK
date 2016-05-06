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

/** Encodes dictionary to a http query

 @param dictionary The dictionary to be encoded
 @return The http query
 */
+ (NSString *)encodedHttpQueryForDictionary:(NSDictionary *)dictionary;

/** Encodes dictionary to a http post body

 @param dictionary The dictionary to be encoded
 @return The http post body
 */
+ (NSString *)encodedHttpBodyForDictionary:(NSDictionary *)dictionary;

/** URL encodes the specified string

 @param unescaped String to be encoded
 @return Encoded NSString
 */
+ (NSString *)urlEncodeString:(NSString *)unescaped;

/** Extracts a query parameter from a URL

 @param url URL
 @param key Parameter to be found
 @return Value for the specified key otherwise nil
 */
+ (NSString *)getUrlParameter:(NSURL *)url forKey:(NSString *)key;

/** Validates a email address

 Based on RFC 2822

 @param email The email to validate
 @return YES if the email is valid, otherwise NO
 */
//
+ (BOOL)validateEmail:(NSString *)email;

@end
//
// Created by mikaellindstrom on 9/13/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface SPiDUtils : NSObject

//+ (NSString *)addParameterToString:(NSString *)string withParameterKey:(NSString *)parameterKey withValue:(NSString *)parameterValue;

+ (NSURL *)urlEncodeString:(NSString *)unescaped;

+ (NSString *)getUrlParameter:(NSURL *)url forKey:(NSString *)key;

//+ (NSURL *)stripQueryFromURL:(NSURL *)url;

@end
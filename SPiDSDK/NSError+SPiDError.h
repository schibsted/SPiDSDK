//
//  NSError+SPiDError.h
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (SPiDError)

+ (id)spidErrorFromJSONData:(NSDictionary *)dictionary;

+ (id)spidOauth2ErrorWithString:(NSString *)error;

+ (id)spidOauth2ErrorWithCode:(NSInteger)errorCode userInfo:(NSDictionary *)userInfo;

+ (id)spidApiErrorWithCode:(NSInteger)errorCode userInfo:(NSDictionary *)userInfo;

@end

//
//  SPiDStatus
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDRequest.h"
#import "SPiDResponse.h"

@interface SPiDStatus : NSObject
+ (void)runStatusRequest;

+ (SPiDRequest *)statusRequestWithCompletionHandler:(void (^)(SPiDResponse *))completionHandler;

+ (NSString *)vendorId;

+ (NSString *)spidUserAgent;

@end
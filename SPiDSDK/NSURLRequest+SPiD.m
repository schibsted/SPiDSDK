//
//  NSURLRequest+SPiD.m
//  SPiDSDK
//
//  Created by Joakim Gyllström on 2015-12-18.
//  Copyright © 2015 Mikael Lindström. All rights reserved.
//

#import "NSURLRequest+SPiD.h"
#import "SPiDStatus.h"

@implementation NSURLRequest (SPiD)

+ (NSURLRequest *)sp_requestWithURL:(NSURL *)URL method:(NSString *)method andBody:(NSString *)body {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:method];
    
    [request setValue:[SPiDStatus spidUserAgent] forHTTPHeaderField:@"User-Agent"];
    SPiDDebugLog(@"Running request: %@", URL);
    
    if (body) {
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return [request copy];
}

@end

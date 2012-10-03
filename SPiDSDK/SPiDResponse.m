//
//  SPiDResponse.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/19/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDResponse.h"
#import "SPiDClient.h"
#import "NSError+SPiDError.h"

@implementation SPiDResponse

@synthesize error = _error;
@synthesize data = _data;
@synthesize rawJSON = _rawJSON;

- (id)initWithJSONData:(NSData *)data {
    self = [super init];
    if (self) {
        NSError *jsonError = nil;
        if ([data length] > 0) {
            [self setRawJSON:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            [self setData:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError]];
            if (jsonError) {
                [self setError:[self error]];
                SPiDDebugLog(@"JSON parse error: %@", [[self error] description]);
            } else {
                if ([[self data] objectForKey:@"error"] && ![[[self data] objectForKey:@"error"] isEqual:[NSNull null]]) {
                    [self setError:[NSError errorFromJSONData:[self data]]];
                    SPiDDebugLog(@"Received error: %@", [[self data] objectForKey:@"error"]);
                } // else everything ok
            }
        } // TODO: if message is empty?

    }
    return self;
}

@end
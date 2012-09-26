//
//  SPiDResponse.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/19/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDResponse.h"

@implementation SPiDResponse {

}

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
                NSLog(@"SPiDSDK json error: %@", [[self error] description]);
            } else {
                if ([[self data] objectForKey:@"error"] && ![[[self data] objectForKey:@"error"] isEqual:[NSNull null]]) {
                    [self setError:[NSError errorWithDomain:@"asdf" code:1 userInfo:nil]];
                    NSLog(@"SPiDSDK api error: %@", [[self data] objectForKey:@"error"]);
                } // else everything ok
            }
        } // else, errorhandling if no response is recieved?

    }
    return self;
}

@end
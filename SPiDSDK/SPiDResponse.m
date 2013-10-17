//
//  SPiDResponse.m
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDClient.h"
#import "SPiDSDK.h"
#import "SPiDResponse.h"
#import "NSError+SPiDError.h"

@implementation SPiDResponse

- (id)initWithJSONData:(NSData *)data {
    self = [super init];
    if (self) {
        NSError *jsonError = nil;
        if ([data length] > 0) {
            [self setRawJSON:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            [self setMessage:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError]];
            if (jsonError) {
                [self setError:jsonError];
                SPiDDebugLog(@"JSON parse error: %@", self.rawJSON);
            } else {
                if ([[self message] objectForKey:@"error"] && ![[[self message] objectForKey:@"error"] isEqual:[NSNull null]]) {
                    [self setError:[NSError spidErrorFromJSONData:[self message]]];
                } // else everything ok
            }
        } else {
            [self setError:[NSError spidApiErrorWithCode:SPiDUserAbortedLogin userInfo:
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Recevied empty response", @"error", nil]]];
        }
    }
    return self;
}

- (id)initWithError:(NSError *)error {
    self = [super self];
    if (self) {
        [self setError:error];
    }
    return self;
}

@end

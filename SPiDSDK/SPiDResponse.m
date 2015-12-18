//
//  SPiDResponse.m
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDResponse.h"
#import "SPiDClient.h"
#import "NSError+SPiD.h"

@implementation SPiDResponse

- (id)initWithJSONData:(NSData *)data {
    self = [super init];
    if (self) {
        NSError *jsonError = nil;
        if ([data length] > 0) {
            [self setRawJSON:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            [self setMessage:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError]];
            if (jsonError) {
                self.error = jsonError;
                SPiDDebugLog(@"JSON parse error: %@", self.rawJSON);
            } else {
                if ([[self message] objectForKey:@"error"] && ![[[self message] objectForKey:@"error"] isEqual:[NSNull null]]) {
                    [self setError:[NSError sp_errorFromJSONData:[self message]]];
                } // else everything ok
            }
        } else {
            [self setError:[NSError sp_apiErrorWithCode:SPiDUserAbortedLogin reason:@"ApiException" descriptions:[NSDictionary dictionaryWithObjectsAndKeys:@"Recevied empty response", @"error", nil]]];
        }
    }
    return self;
}

- (id)initWithError:(NSError *)error {
    self = [super self];
    if (self) {
        self.error = error;
    }
    return self;
}

@end
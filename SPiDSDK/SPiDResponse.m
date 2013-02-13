//
//  SPiDResponse.m
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDResponse.h"
#import "SPiDClient.h"
#import "NSError+SPiDError.h"

@implementation SPiDResponse

@synthesize error = _error;
@synthesize message = _message;
@synthesize rawJSON = _rawJSON;

- (id)initWithJSONData:(NSData *)data {
    self = [super init];
    if (self) {
        NSError *jsonError = nil;
        if ([data length] > 0) {
            [self setRawJSON:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            [self setMessage:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError]];
            if (jsonError) {
                [self setError:jsonError];
                SPiDDebugLog(@"JSON parse error: %@", [[self error] description]);
            } else {
                if ([[self message] objectForKey:@"error"] && ![[[self message] objectForKey:@"error"] isEqual:[NSNull null]]) {
                    [self setError:[NSError errorFromJSONData:[self message]]];
                } // else everything ok
            }
        } else {
            [self setError:[NSError apiErrorWithCode:SPiDAPIExceptionErrorCode description:@"Recevied empty response" reason:@"ApiException"]];
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

+ (id)responseWithError:(NSError *)error {
    return [[self alloc] initWithError:error];
}
@end
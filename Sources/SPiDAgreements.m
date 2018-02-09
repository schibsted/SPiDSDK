//
//  SPiDAgreements.m
//  SPiDSDK
//
//  Created by Joakim Gyllström on 2016-12-19.
//  Copyright © 2016 Mikael Lindström. All rights reserved.
//

#import "SPiDAgreements.h"

NSString * const kDataKey = @"data";
NSString * const kAgreementsKey = @"agreements";
NSString * const kPlatformKey = @"platform";
NSString * const kClientKey = @"client";

@interface SPiDAgreements ()

@property (nonatomic, assign, readwrite) BOOL client;
@property (nonatomic, assign, readwrite) BOOL platform;

@end

@implementation SPiDAgreements

+ (SPiDAgreements *)parseAgreementsFrom:(NSDictionary *)jsonDictionary {
    if(![jsonDictionary isKindOfClass:[NSDictionary class]]) { return nil; } // Since this is Objective-C make sure we get what we want

    NSNumber *client = jsonDictionary[kDataKey][kAgreementsKey][kClientKey];
    NSNumber *platform = jsonDictionary[kDataKey][kAgreementsKey][kPlatformKey];

    if(![client isKindOfClass:[NSNumber class]] || ![platform isKindOfClass:[NSNumber class]]) { return nil; } // Did those keys contain the desired types of values?

    SPiDAgreements *agreements = [SPiDAgreements new];
    agreements.client = client.boolValue;
    agreements.platform = platform.boolValue;

    return agreements;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Client: %d\nPlatform: %d", self.client, self.platform];
}

@end

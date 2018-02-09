//
//  SPiDAgreements.h
//  SPiDSDK
//
//  Created by Joakim Gyllström on 2016-12-19.
//  Copyright © 2016 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPiDAgreements : NSObject

@property (nonatomic, assign, readonly) BOOL client;
@property (nonatomic, assign, readonly) BOOL platform;

+ (SPiDAgreements *)parseAgreementsFrom:(NSDictionary *)jsonDictionary;

@end

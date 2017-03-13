//
//  SPiDTokenStorageUserDefaultsBackend.h
//  SPiDSDK
//
//  Created by Daniel Lazarenko on 07/03/2017.
//

#import <Foundation/Foundation.h>
#import "SPiDTokenStorage.h"

@interface SPiDTokenStorageUserDefaultsBackend : NSObject <SPiDTokenStorageBackend>

- (instancetype)initWithUserDefaults:(NSUserDefaults *)defaults;

@end

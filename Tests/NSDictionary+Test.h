//
//  NSDictionary+NSDictionary_Test.h
//  SPiDSDK
//
//  Created by Work on 2017-02-15.
//  Copyright © 2017 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Test)

/**
 Helper for getting JSON stubs from disk

 @param stubName The name of the stub
 @return A dictionary or nil on errors
 */
+ (NSDictionary *)sp_JSONStubWithName:(NSString *)stubName;

@end

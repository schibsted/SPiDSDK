//
//  SPiDUser
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SPiDUser : NSObject
- (void)createAccountWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSError *))completionHandler;

@end
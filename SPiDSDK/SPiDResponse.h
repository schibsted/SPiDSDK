//
//  SPiDResponse.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/19/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPiDResponse : NSObject

@property(strong, nonatomic) NSError *error;
@property(strong, nonatomic) NSDictionary *data;
@property(strong, nonatomic) NSString *rawJSON;

- (id)initWithJSONData:(NSData *)data;

@end
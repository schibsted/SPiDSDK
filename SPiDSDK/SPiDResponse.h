//
//  SPiDResponse.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/19/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `SPiDResponse` is created for each response from SPiD made by a `SPiDRequest`

 It contains the data as both a object and as raw JSON.

 @warning Received should always check the error property upon receiving a response.
 */

@interface SPiDResponse : NSObject

///---------------------------------------------------------------------------------------
/// @name Public properties
///---------------------------------------------------------------------------------------

/** Contains error if there was any, otherwise nil */
@property(strong, nonatomic) NSError *error;

/** Received JSON data converted to a dictionary */
@property(strong, nonatomic) NSDictionary *data;

/** Received JSON data as a raw string */
@property(strong, nonatomic) NSString *rawJSON;

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** Initializes SPiD response with the received data

 @param data Data received from SPiD
 @return SPiDAccessToken
 */
- (id)initWithJSONData:(NSData *)data;

// list or
@end
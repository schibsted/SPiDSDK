//
//  SPiDResponse.h
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPiDError;

/**
 `SPiDResponse` is created for each response from SPiD made by a `SPiDRequest`

 It contains the message as both a object and as raw JSON.

 @warning Received should always check the error property upon receiving a response.
 */

@interface SPiDResponse : NSObject

///---------------------------------------------------------------------------------------
/// @name Properties
///---------------------------------------------------------------------------------------

/** Contains error if there was any, otherwise nil */
@property(strong, nonatomic) NSError *error;

/** Received JSON message converted to a dictionary */
@property(strong, nonatomic) NSDictionary *message;

/** Received JSON message as a raw string */
@property(strong, nonatomic) NSString *rawJSON;

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** Initializes SPiD response with the received message

 @param data Data received from SPiD
 @return SPiDAccessToken
 */
- (id)initWithJSONData:(NSData *)data;

/** Initializes SPiD response with a error

 @param error The received error
 @return SPiDAccessToken
 */
- (id)initWithError:(NSError *)error;

@end
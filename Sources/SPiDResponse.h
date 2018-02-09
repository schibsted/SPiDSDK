//
//  SPiDResponse.h
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

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
@property(strong, nonatomic, nullable) NSError *error;

/** Received JSON message converted to a dictionary */
@property(strong, nonatomic) NSDictionary<NSString *, id> *message;

/** Received JSON message as a raw string */
@property(strong, nonatomic) NSString *rawJSON;

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** Initializes SPiD response with the received message

 @param data Data received from SPiD
 @return SPiDAccessToken
 */
- (instancetype)initWithJSONData:(nullable NSData *)data;

/** Initializes SPiD response with a error

 @param error The received error
 @return SPiDAccessToken
 */
- (instancetype)initWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END

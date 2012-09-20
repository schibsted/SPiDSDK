//
//  SPiDClient.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDURL.h"

typedef void (^SPiDAuthorizationURLHandler)(NSURL *preparedURL);

typedef void (^SPiDCompletionHandler)(NSError *error);

@interface SPiDClient : NSObject <NSURLConnectionDelegate>

@property(strong, nonatomic) NSString *clientID;
@property(strong, nonatomic) NSString *clientSecret;
@property(strong, nonatomic) NSString *code; // TODO: Should be private
@property(strong, nonatomic) NSString *accessToken; // TODO: Should be private
@property(strong, nonatomic) NSString *appURLScheme;
@property(strong, nonatomic) NSURL *redirectURL; // TODO: Default to appURLScheme://SPiD/{login|logout|failure}
@property(strong, nonatomic) NSURL *spidURL;
@property(strong, nonatomic) NSURL *authorizationURL;
@property(strong, nonatomic) NSURL *tokenURL;
@property(strong, nonatomic) NSMutableData *receivedData; // TODO: move to new auth class
@property(copy) SPiDCompletionHandler completionHandler; // TODO: should be typedef

+ (SPiDClient *)sharedInstance;

- (void)setClientID:(NSString *)clientID
    andClientSecret:(NSString *)clientSecret
    andAppURLScheme:(NSString *)appURLSchema
         andSPiDURL:(NSURL *)spidURL;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)requestSPiDAuthorizationWithCompletionHandler:(SPiDCompletionHandler)completionHandler; // TODO: block as typedef?

@end

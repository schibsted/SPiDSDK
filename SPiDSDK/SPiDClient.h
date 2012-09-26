//
//  SPiDClient.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/11/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDConstants.h"
#import "SPiDUtils.h"

@class SPiDAuthorizationRequest;
@class SPiDResponse;

typedef void (^SPiDAuthorizationCompletionHandler)(NSError *error);

typedef void (^SPiDCompletionHandler)(SPiDResponse *response);

@interface SPiDClient : NSObject

@property(strong, nonatomic) NSString *clientID;
@property(strong, nonatomic) NSString *clientSecret;
@property(strong, nonatomic) NSString *appURLScheme;
@property(strong, nonatomic) NSURL *redirectURI; // TODO: Default to appURLScheme://SPiD/{login|logout|failure}
@property(strong, nonatomic) NSURL *spidURL;
@property(strong, nonatomic) NSURL *authorizationURL;
@property(strong, nonatomic) NSURL *tokenURL;
@property(nonatomic) BOOL saveToKeychain;

+ (SPiDClient *)sharedInstance;

- (void)setClientID:(NSString *)clientID
    andClientSecret:(NSString *)clientSecret
    andAppURLScheme:(NSString *)appURLSchema
         andSPiDURL:(NSURL *)spidURL;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)requestSPiDAuthorizationWithCompletionHandler:(SPiDAuthorizationCompletionHandler)completionHandler;

- (void)doAuthenticatedMeRequestWithCompletionHandler:(SPiDCompletionHandler)completionHandler;

- (void)doAuthenticatedLoginsRequestWithUserID:(NSString *)userID andCompletionHandler:(SPiDCompletionHandler)completionHandler;

@end

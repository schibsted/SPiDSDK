//
//  SPiDRequest.h
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/17/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPiDClient.h"

@interface SPiDRequest : NSObject <NSURLConnectionDelegate> {
@private
    NSURL *url;
    NSString *httpMethod;
    NSMutableData *receivedData;
    SPiDCompletionHandler completionHandler;
}

- (void)doAuthenticatedSPiDGetRequestWithURL:(NSURL *)url;

- (void)doAuthenticatedMeRequestWithCompletionHandler:(SPiDCompletionHandler)handler;

- (void)doAuthenticatedLogoutRequestWithCompletionHandler:(SPiDCompletionHandler)handler;

- (void)doAuthenticatedLoginsRequestWithCompletionHandler:(SPiDCompletionHandler)handler andUserID:(NSString *)userID;

// TODO: Should have retry method

@end
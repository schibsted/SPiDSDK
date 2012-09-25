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

    void (^completionHandler)(NSDictionary *dict);

}

- (void)doAuthenticatedSPiDGetRequestWithURL:(NSURL *)url;

- (void)doAuthenticatedMeRequestWithCompletionHandler:(void (^)(NSDictionary *dict))completionHandler;

- (void)doAuthenticatedLogoutRequestWithCompletionHandler:(void (^)(NSDictionary *dict))completionHandler;

- (void)doAuthenticatedLoginsRequestWithCompletionHandler:(void (^)(NSDictionary *dict))completionHandler andUserID:(NSString *)userID;

// TODO: Should have retry method

@end
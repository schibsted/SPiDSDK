//
//  SPiDTokenRequest
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/21/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDTokenRequest.h"

@implementation SPiDTokenRequest

+ (SPiDTokenRequest *)clientTokenRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSDictionary *postData = [self clientTokenPostData];
    return (SPiDTokenRequest *) [self postRequestWithPath:@"/oauth/token" andHTTPBody:postData andCompletionHandler:completionHandler];
}

+ (SPiDTokenRequest *)userTokenRequestWithUsername:(NSString *)username andPassword:(NSString *)password andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSDictionary *postData = [self userTokenPostDataWithUsername:username andPassword:password];
    return (SPiDTokenRequest *) [self postRequestWithPath:@"/oauth/token" andHTTPBody:postData andCompletionHandler:completionHandler];
}

+ (NSDictionary *)clientTokenPostData {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:[client clientID] forKey:@"client_id"];
    [data setValue:@"client_credentials" forKey:@"grant_type"];
    [data setValue:[client clientSecret] forKey:@"client_secret"];
    return data;
}

+ (NSDictionary *)userTokenPostDataWithUsername:(NSString *)username andPassword:(NSString *)password {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:[client clientID] forKey:@"client_id"];
    [data setValue:@"password" forKey:@"grant_type"];
    [data setValue:[client clientSecret] forKey:@"client_secret"];
    [data setValue:username forKey:@"username"];
    [data setValue:password forKey:@"password"];
    return data;
}

@end
//
//  SPiDTokenRequest
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/21/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDTokenRequest.h"


@implementation SPiDTokenRequest {

}
+ (SPiDTokenRequest *)nativeTokenRequestWithUsername:(NSString *)username andPassword:(NSString *)password andCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSDictionary *postData = [self nativePostDataWithUsername:username andPassword:password];
    return (SPiDTokenRequest *) [self postRequestWithPath:@"/oauth/token" andHTTPBody:postData andCompletionHandler:completionHandler];
}

+ (NSDictionary *)nativePostDataWithUsername:(NSString *)username andPassword:(NSString *)password {
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
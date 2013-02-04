//
//  SPiDTokenRequest
//  SPiDSDK
//
//  Created by mikaellindstrom on 1/21/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDTokenRequest.h"
#import "NSError+SPiDError.h"
#import "SPiDAccessToken.h"
#import "SPiDKeychainWrapper.h"

@implementation SPiDTokenRequest {
@private

    void(^_authCompletionHandler)(NSError *error);

}

- (id)initPostTokenRequestWithPath:(NSString *)requestPath andHTTPBody:(NSDictionary *)body andAuthCompletionHandler:(void (^)(NSError *error))authCompletionHandler {
    self = [SPiDTokenRequest requestWithPath:requestPath andHTTPMethod:@"POST" andHTTPBody:body andCompletionHandler:nil];
    _authCompletionHandler = authCompletionHandler;
    return self;
}

+ (SPiDTokenRequest *)clientTokenRequestWithCompletionHandler:(void (^)(NSError *error))completionHandler {
    NSDictionary *postData = [self clientTokenPostData];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" andHTTPBody:postData andAuthCompletionHandler:completionHandler];
    return request;
}

+ (SPiDTokenRequest *)userTokenRequestWithUsername:(NSString *)username andPassword:(NSString *)password andAuthCompletionHandler:(void (^)(NSError *error))authCompletionHandler {
    NSDictionary *postData = [self userTokenPostDataWithUsername:username andPassword:password];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" andHTTPBody:postData andAuthCompletionHandler:authCompletionHandler];
    return request;
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *jsonError = nil;
    NSDictionary *jsonObject = nil;
    SPiDDebugLog(@"Response token data: %@", [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding]);
    if ([_receivedData length] > 0) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingMutableContainers error:&jsonError];
    } else {
        _authCompletionHandler([NSError oauth2ErrorWithCode:SPiDAPIExceptionErrorCode description:@"Recevied empty response" reason:@"ApiException"]);
    }

    if (!jsonError) {
        if ([jsonObject objectForKey:@"error"] && ![[jsonObject objectForKey:@"error"] isEqual:[NSNull null]]) {
            NSError *error = [NSError errorFromJSONData:jsonObject];
            _authCompletionHandler(error);
        } else if (_receivedData) {
            SPiDAccessToken *accessToken = [[SPiDAccessToken alloc] initWithDictionary:jsonObject];
            [SPiDKeychainWrapper storeInKeychainAccessTokenWithValue:accessToken forIdentifier:AccessTokenKeychainIdentification];
            [[SPiDClient sharedInstance] setAccessToken:accessToken];
            _authCompletionHandler(nil);
        }
    } else {
        SPiDDebugLog(@"Received jsonerror: %@", [jsonError description]);
        _authCompletionHandler(jsonError);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SPiDDebugLog(@"SPiDSDK error: %@", [error description]);
    _authCompletionHandler(error);
}

@end
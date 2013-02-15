//
//  SPiDTokenRequest
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDTokenRequest.h"
#import "NSError+SPiDError.h"
#import "SPiDAccessToken.h"
#import "SPiDKeychainWrapper.h"
#import "SPiDJwt.h"

@implementation SPiDTokenRequest {
@private

    void(^_tokenCompletionHandler)(NSError *error);

}

+ (SPiDTokenRequest *)clientTokenRequestWithCompletionHandler:(void (^)(NSError *error))completionHandler {
    NSDictionary *postData = [self clientTokenPostData];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:postData completionHandler:completionHandler];
    return request;
}

+ (SPiDTokenRequest *)userTokenRequestWithCode:(NSString *)code authCompletionHandler:(void (^)(NSError *error))authCompletionHandler {
    NSDictionary *postData = [self userTokenPostDataWithCode:code];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:postData completionHandler:authCompletionHandler];
    return request;
}

+ (SPiDTokenRequest *)userTokenRequestWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(NSError *error))completionHandler {
    NSDictionary *postData = [self userTokenPostDataWithUsername:username password:password];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:postData completionHandler:completionHandler];
    return request;
}

+ (SPiDTokenRequest *)userTokenRequestWithFacebookAppID:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate completionHandler:(void (^)(NSError *))completionHandler {
    NSString *jwtString = [self facebookJwtStringWithAppId:appId facebookToken:facebookToken expirationDate:expirationDate];
    if (jwtString == nil) {
        return nil; // Should not happen, throw exception
    }
    NSDictionary *body = [SPiDTokenRequest userTokenPostDataWithJwt:jwtString];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:body completionHandler:completionHandler];
    return request;
}

+ (SPiDTokenRequest *)refreshTokenRequestWithCompletionHandler:(void (^)(NSError *))completionHandler {
    SPiDAccessToken *accessToken = [SPiDClient sharedInstance].accessToken;
    if (accessToken == nil || accessToken.refreshToken == nil) {
        SPiDDebugLog(@"No access token, cannot refreshTrying to refresh access token with refresh token: %@", accessToken.refreshToken);
        return nil;
    }
    SPiDDebugLog(@"Trying to refresh access token with refresh token: %@", accessToken.refreshToken);
    NSDictionary *postData = [self refreshTokenPostDataWithAccessToken:accessToken];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:postData completionHandler:completionHandler];
    return request;
}

- (id)initPostTokenRequestWithPath:(NSString *)requestPath body:(NSDictionary *)body completionHandler:(void (^)(NSError *error))completionHandler {
    self = (SPiDTokenRequest*)[SPiDTokenRequest requestWithPath:requestPath method:@"POST" body:body completionHandler:nil];
    _tokenCompletionHandler = completionHandler;
    return self;
}

+ (NSDictionary *)clientTokenPostData {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:[client clientID] forKey:@"client_id"];
    [data setValue:[client clientSecret] forKey:@"client_secret"];
    [data setValue:@"client_credentials" forKey:@"grant_type"];
    return data;
}

/** Generates the access token post data from a authorization code

 @result Access token request data
 */
+ (NSDictionary *)userTokenPostDataWithCode:(NSString *)code {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:[client clientID] forKey:@"client_id"];
    [data setValue:[client clientSecret] forKey:@"client_secret"];
    [data setValue:@"authorization_code" forKey:@"grant_type"];
    [data setValue:client.redirectURI.absoluteString forKey:@"redirect_uri"];
    [data setValue:code forKey:@"code"];
    return data;
}

+ (NSDictionary *)userTokenPostDataWithUsername:(NSString *)username password:(NSString *)password {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:[client clientID] forKey:@"client_id"];
    [data setValue:[client clientSecret] forKey:@"client_secret"];
    [data setValue:@"password" forKey:@"grant_type"];
    [data setValue:username forKey:@"username"];
    [data setValue:password forKey:@"password"];
    return data;
}

+ (NSDictionary *)userTokenPostDataWithJwt:(NSString *)jwtString {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:client.clientSecret forKey:@"client_secret"];
    [data setValue:client.clientID forKey:@"client_id"];
    [data setValue:@"urn:ietf:params:oauth:grant-type:jwt-bearer" forKey:@"grant_type"];
    [data setValue:jwtString forKey:@"assertion"];
    //[data setValue:client.tokenURL.absoluteString forKey:@"redirect_uri"];
    return data;
}


/** Generates the access token refresh post data from a access token

 @param accessToken ´SPiDAccessToken` containing the refresh token
 @return Token refresh request data
 */
+ (NSDictionary *)refreshTokenPostDataWithAccessToken:(SPiDAccessToken *)accessToken {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:client.clientID forKey:@"client_id"];
    [data setValue:client.clientSecret forKey:@"client_secret"];
    [data setValue:@"refresh_token" forKey:@"grant_type"];
    [data setValue:accessToken.refreshToken forKey:@"refresh_token"];
    //[data setValue:client.tokenURL.absoluteString forKey:@"redirect_uri"];
    return data;
}

+ (NSString *)facebookJwtStringWithAppId:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:appId forKey:@"iss"];
    [dictionary setValue:@"authorization" forKey:@"sub"];
    [dictionary setValue:[SPiDClient sharedInstance].tokenURL.absoluteString forKey:@"aud"];
    [dictionary setValue:expirationDate.description forKey:@"exp"];
    [dictionary setValue:@"facebook" forKey:@"token_type"];
    [dictionary setValue:facebookToken forKey:@"token_value"];
    SPiDJwt *jwt = [SPiDJwt jwtTokenWithDictionary:dictionary];
    NSString *jwtString = jwt.encodedJwtString;
    return jwtString;
}

// NSURLConnection methods
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *jsonError = nil;
    NSDictionary *jsonObject = nil;
    SPiDDebugLog(@"Response token data: %@", [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding]);
    if ([_receivedData length] > 0) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingMutableContainers error:&jsonError];
    } else {
        _tokenCompletionHandler([NSError oauth2ErrorWithCode:SPiDAPIExceptionErrorCode description:@"Recevied empty response" reason:@"ApiException"]);
    }

    if (!jsonError) {
        if ([jsonObject objectForKey:@"error"] && ![[jsonObject objectForKey:@"error"] isEqual:[NSNull null]]) {
            NSError *error = [NSError errorFromJSONData:jsonObject];
            _tokenCompletionHandler(error);
        } else /*if (_receivedData)*/ {
            SPiDAccessToken *accessToken = [[SPiDAccessToken alloc] initWithDictionary:jsonObject];
            [SPiDKeychainWrapper storeInKeychainAccessTokenWithValue:accessToken forIdentifier:AccessTokenKeychainIdentification];
            [[SPiDClient sharedInstance] setAccessToken:accessToken];
            _tokenCompletionHandler(nil);
        }
    } else {
        SPiDDebugLog(@"Received jsonerror: %@", [jsonError description]);
        _tokenCompletionHandler(jsonError);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SPiDDebugLog(@"SPiDSDK error: %@", [error description]);
    _tokenCompletionHandler(error);
}

@end
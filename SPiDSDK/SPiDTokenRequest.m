//
//  SPiDTokenRequest
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDTokenRequest.h"
#import "SPiDError.h"
#import "SPiDKeychainWrapper.h"
#import "SPiDJwt.h"

@interface SPiDTokenRequest ()

/** Generates a facebook JWT token as a encoded string

 @param appId Facebook appID
 @param facebookToken Facebook access token
 @param expirationDate Expiration date for the facebook token
 @return JWT as a encoded string
 */
+ (NSString *)facebookJwtStringWithAppId:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate;

/** Generates post data for a token refresh

 @param accessToken `SPiDAccessToken` to be refreshed
 @return Dictionary containing the post data
 */
+ (NSDictionary *)refreshTokenPostDataWithAccessToken:(SPiDAccessToken *)accessToken;

/** Generates post data for a user token request using JWT

 @param jwtString JWT as a encoded string
 @return Dictionary containing the post data
 */
+ (NSDictionary *)userTokenPostDataWithJwt:(NSString *)jwtString;

/** Generates post data for a user token request using user credentials

 @param username The username
 @param password The password
 @return Dictionary containing the post data
 */
+ (NSDictionary *)userTokenPostDataWithUsername:(NSString *)username password:(NSString *)password;

/** Generates post data for a access token request using authorization code

 @param code Authorization code
 @return Dictionary containing the post data
 */
+ (NSDictionary *)userTokenPostDataWithCode:(NSString *)code;

/** Generates post data for a client token request

 @return A dictionary containing the post data
 */
+ (NSDictionary *)clientTokenPostData;

/** Initializes a token request

 @param requestPath Path to token endpoint
 @param body Post body
 @param completionHandler Called on request completion or error
 @return SPiDTokenRequest
 */
- (id)initPostTokenRequestWithPath:(NSString *)requestPath body:(NSDictionary *)body completionHandler:(void (^)(SPiDError *))completionHandler;

/** NSURLConnectionDelegate method

 Sent when a connection has finished loading successfully.

 @param connection The connection sending the message.
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

/** NSURLConnectionDelegate method

 Sent when a connection fails to load its request successfully.

 @param connection The connection sending the message.
 @param error An error object containing details of why the connection failed to load the request successfully.
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end

@implementation SPiDTokenRequest {
@private

    void(^_tokenCompletionHandler)(SPiDError *error);

}

+ (id)clientTokenRequestWithCompletionHandler:(void (^)(SPiDError *error))completionHandler {
    NSDictionary *postData = [self clientTokenPostData];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:postData completionHandler:completionHandler];
    return request;
}

+ (id)userTokenRequestWithCode:(NSString *)code completionHandler:(void (^)(SPiDError *error))completionHandler {
    NSDictionary *postData = [self userTokenPostDataWithCode:code];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:postData completionHandler:completionHandler];
    return request;
}

+ (id)userTokenRequestWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(SPiDError *error))completionHandler {
    NSString *trimmedUserName = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSDictionary *postData = [self userTokenPostDataWithUsername:trimmedUserName password:password];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:postData completionHandler:completionHandler];
    return request;
}

+ (id)userTokenRequestWithFacebookAppID:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate completionHandler:(void (^)(SPiDError *))completionHandler {
    NSString *jwtString = [self facebookJwtStringWithAppId:appId facebookToken:facebookToken expirationDate:expirationDate];
    if (jwtString == nil) {
        return nil; // Should not happen, throw exception
    }
    NSDictionary *body = [SPiDTokenRequest userTokenPostDataWithJwt:jwtString];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:body completionHandler:completionHandler];
    return request;
}

+ (id)refreshTokenRequestWithCompletionHandler:(void (^)(SPiDError *))completionHandler {
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

///---------------------------------------------------------------------------------------
/// @name Private Methods
///---------------------------------------------------------------------------------------
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

+ (NSDictionary *)userTokenPostDataWithCode:(NSString *)code {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:[client clientID] forKey:@"client_id"];
    [data setValue:[client clientSecret] forKey:@"client_secret"];
    [data setValue:@"authorization_code" forKey:@"grant_type"];
    if ([client.redirectURI.absoluteString hasSuffix:@"/"]) {
        [data setValue:[client.redirectURI.absoluteString stringByAppendingString:@"login"] forKey:@"redirect_uri"];
    } else {
        [data setValue:[client.redirectURI.absoluteString stringByAppendingString:@"/login"] forKey:@"redirect_uri"];
    }
    [data setValue:code forKey:@"code"];
    return data;
}

+ (NSDictionary *)clientTokenPostData {
    SPiDClient *client = [SPiDClient sharedInstance];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:[client clientID] forKey:@"client_id"];
    [data setValue:[client clientSecret] forKey:@"client_secret"];
    [data setValue:@"client_credentials" forKey:@"grant_type"];
    return data;
}

- (id)initPostTokenRequestWithPath:(NSString *)requestPath body:(NSDictionary *)body completionHandler:(void (^)(SPiDError *error))completionHandler {
    self = (SPiDTokenRequest *) [SPiDTokenRequest requestWithPath:requestPath method:@"POST" body:body completionHandler:nil];
    _tokenCompletionHandler = completionHandler;
    return self;
}

// NSURLConnection methods
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    SPiDError *jsonError = nil;
    NSDictionary *jsonObject = nil;
    SPiDDebugLog(@"Response token data: %@", [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding]);
    if ([_receivedData length] > 0) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingMutableContainers error:&jsonError];
    } else {
        _tokenCompletionHandler([SPiDError oauth2ErrorWithCode:SPiDAPIExceptionErrorCode reason:@"ApiException" descriptions:[NSDictionary dictionaryWithObjectsAndKeys:@"Recevied empty response", @"error", nil]]);
    }

    if (!jsonError) {
        if ([jsonObject objectForKey:@"error"] && ![[jsonObject objectForKey:@"error"] isEqual:[NSNull null]]) {
            SPiDError *error = [SPiDError errorFromJSONData:jsonObject];
            _tokenCompletionHandler(error);
        } else /*if (_receivedData)*/ {
            SPiDAccessToken *accessToken = [[SPiDAccessToken alloc] initWithDictionary:jsonObject];
            [SPiDKeychainWrapper storeInKeychainAccessTokenWithValue:accessToken forIdentifier:AccessTokenKeychainIdentification];
            [[SPiDClient sharedInstance] setAccessToken:accessToken];
            [[SPiDClient sharedInstance] authorizationComplete];
            _tokenCompletionHandler(nil);
        }
    } else {
        SPiDDebugLog(@"Received jsonerror: %@", [jsonError description]);
        _tokenCompletionHandler([SPiDError apiErrorWithCode:SPiDJSONParseErrorCode reason:@"Faild to parse JSON response" descriptions:[NSDictionary dictionaryWithObject:[jsonError description] forKey:@"error"]]);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SPiDDebugLog(@"SPiDSDK error: %@", [error description]);
    _tokenCompletionHandler([SPiDError errorFromNSError:error]);
}

@end

//
//  SPiDTokenRequest
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDTokenRequest.h"
#import "NSError+SPiD.h"
#import "SPiDAccessToken.h"
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
- (instancetype)initPostTokenRequestWithPath:(NSString *)requestPath body:(NSDictionary *)body completionHandler:(void (^ __nullable)(NSError *))completionHandler;

@property (nonatomic, copy) void(^tokenCompletionHandler)(NSError *error);

@end


@interface SPiDClient (SPiDClientPrivateAccessTokenSetter)
- (void)setAndStoreAccessToken:(SPiDAccessToken *)accessToken;
@end


@implementation SPiDTokenRequest

+ (instancetype)clientTokenRequestWithCompletionHandler:(void (^)(NSError *error))completionHandler {
    NSDictionary *postData = [self clientTokenPostData];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:postData completionHandler:completionHandler];
    return request;
}

+ (instancetype)userTokenRequestWithCode:(NSString *)code completionHandler:(void (^)(NSError *error))completionHandler {
    NSDictionary *postData = [self userTokenPostDataWithCode:code];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:postData completionHandler:completionHandler];
    return request;
}

+ (instancetype)userTokenRequestWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(NSError *error))completionHandler {
    NSString *trimmedUserName = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSDictionary *postData = [self userTokenPostDataWithUsername:trimmedUserName password:password];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:postData completionHandler:completionHandler];
    return request;
}

+ (instancetype)userTokenRequestWithFacebookAppID:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate completionHandler:(void (^)(NSError *))completionHandler {
    NSString *jwtString = [self facebookJwtStringWithAppId:appId facebookToken:facebookToken expirationDate:expirationDate];
    if (jwtString == nil) {
        return nil; // Should not happen, throw exception
    }
    NSDictionary *body = [SPiDTokenRequest userTokenPostDataWithJwt:jwtString];
    SPiDTokenRequest *request = [[self alloc] initPostTokenRequestWithPath:@"/oauth/token" body:body completionHandler:completionHandler];
    return request;
}

+ (instancetype)refreshTokenRequestWithCompletionHandler:(void (^)(NSError *))completionHandler {
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

- (instancetype)initPostTokenRequestWithPath:(NSString *)requestPath body:(NSDictionary *)body completionHandler:(void (^)(NSError *error))completionHandler {
    if ((self = [SPiDTokenRequest requestWithPath:requestPath method:@"POST" body:body completionHandler:nil])) {
        self.tokenCompletionHandler = completionHandler;
    }
    
    return self;
}

- (void)startWithRequest:(NSURLRequest *)request {
    SPiDDebugLog(@"Running token request: %@", request.URL);
    
    NSURLSessionDataTask *task = [[[SPiDClient sharedInstance] URLSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            SPiDDebugLog(@"SPiDSDK error: %@", [error description]);
            self.tokenCompletionHandler(error);
        } else {
            NSError *jsonError = nil;
            NSDictionary *jsonObject = nil;
            SPiDDebugLog(@"Response token data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if ([data length] > 0) {
                jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            } else {
                self.tokenCompletionHandler([NSError sp_oauth2ErrorWithCode:SPiDAPIExceptionErrorCode reason:@"ApiException" descriptions:[NSDictionary dictionaryWithObjectsAndKeys:@"Recevied empty response", @"error", nil]]);
            }
            
            if (!jsonError) {
                if ([jsonObject objectForKey:@"error"] && ![[jsonObject objectForKey:@"error"] isEqual:[NSNull null]]) {
                    NSError *error = [NSError sp_errorFromJSONData:jsonObject];
                    self.tokenCompletionHandler(error);
                } else /*if (_receivedData)*/ {
                    SPiDAccessToken *accessToken = [[SPiDAccessToken alloc] initWithDictionary:jsonObject];
                    [[SPiDClient sharedInstance] setAndStoreAccessToken:accessToken];
                    [[SPiDClient sharedInstance] authorizationComplete];
                    self.tokenCompletionHandler(nil);
                }
            } else {
                SPiDDebugLog(@"Received jsonerror: %@", [jsonError userInfo]);
                self.tokenCompletionHandler([NSError sp_apiErrorWithCode:SPiDJSONParseErrorCode reason:@"Faild to parse JSON response" descriptions:[NSDictionary dictionaryWithObject:[jsonError description] forKey:@"error"]]);
            }
        }
    }];
    
    [task resume];
}

@end

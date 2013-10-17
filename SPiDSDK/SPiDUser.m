//
//  SPiDUser
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDUser.h"
#import "SPiDClient.h"
#import "SPiDSDK.h"
#import "SPiDAccessToken.h"
#import "SPiDResponse.h"
#import "SPiDTokenRequest.h"
#import "SPiDJwt.h"
#import "NSError+SPiDError.h"

@interface SPiDUser ()

/**
*
* @param
* @param
* @return
*/
+ (SPiDJwt *)facebookJwtWithAppId:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate;

/**
*
* @param
* @param
* @return
*/
+ (SPiDJwt *)attachFacebookJwtWithAppId:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate;

/** Generates user credentials post data

 @param email The email
 @param password The password
 @return Dictionary with the post data
*/
- (NSDictionary *)userPostDataWithEmail:(NSString *)email password:(NSString *)password;

/** Generates user credentials post data

 @param jwt The jwt
 @return Dictionary with the post data
*/
- (NSDictionary *)userPostDataWithJwt:(SPiDJwt *)jwt;

- (void)accountRequestWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSError *))completionHandler;

- (void)accountRequestWithJwt:(SPiDJwt *)jwt completionHandler:(void (^)(NSError *))completionHandler;

- (void)attachAccountRequestWithJwt:(SPiDJwt *)jwt completionHandler:(void (^)(NSError *))completionHandler;
@end

@implementation SPiDUser

+ (void)createAccountWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSError *response))completionHandler {
    SPiDUser *user = [[SPiDUser alloc] init];
/*
    // Validate email and password
    SPiDError *validationError = [user validateEmail:email password:password];
    if (validationError != nil) {
        completionHandler(validationError);
    }*/
    // Get client token
    SPiDAccessToken *accessToken = [SPiDClient sharedInstance].accessToken;
    if (accessToken == nil || !accessToken.isClientToken) {
        SPiDDebugLog(@"No client token found, trying to request one");
        SPiDRequest *clientTokenRequest = [SPiDTokenRequest clientTokenRequestWithCompletionHandler:^(NSError *error) {
            if (error) {
                completionHandler(error);
            } else {
                SPiDDebugLog(@"Client token received, creating account");
                [user accountRequestWithEmail:email password:password completionHandler:completionHandler];
            }
        }];
        [clientTokenRequest startRequest];
    } else {
        SPiDDebugLog(@"Client token found, creating account");
        [user accountRequestWithEmail:email password:password completionHandler:completionHandler];
    }
}

+ (void)createAccountWithFacebookAppID:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate completionHandler:(void (^)(NSError *))completionHandler {
    SPiDJwt *jwt = [self facebookJwtWithAppId:appId facebookToken:facebookToken expirationDate:expirationDate];
    SPiDUser *user = [[SPiDUser alloc] init];

    // Get client token
    SPiDAccessToken *accessToken = [SPiDClient sharedInstance].accessToken;
    if (accessToken == nil || !accessToken.isClientToken) {
        SPiDDebugLog(@"No client token found, trying to request one");
        SPiDRequest *clientTokenRequest = [SPiDTokenRequest clientTokenRequestWithCompletionHandler:^(NSError *error) {
            if (error) {
                completionHandler(error);
            } else {
                SPiDDebugLog(@"Client token received, creating account");
                [user accountRequestWithJwt:jwt completionHandler:completionHandler];
            }
        }];
        [clientTokenRequest startRequest];
    } else {
        SPiDDebugLog(@"Client token found, creating account");
        [user accountRequestWithJwt:jwt completionHandler:completionHandler];
    }
}

+ (void)attachAccountWithFacebookAppID:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate completionHandler:(void (^)(NSError *))completionHandler {
    if (![SPiDClient sharedInstance].isAuthorized || [SPiDClient sharedInstance].isClientToken) {
        // TODO: should not be -9999
        completionHandler([NSError spidOauth2ErrorWithCode:-9999 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"User token needed to attach facebook", @"error", nil]]);
    }

    SPiDJwt *jwt = [self attachFacebookJwtWithAppId:appId facebookToken:facebookToken expirationDate:expirationDate];
    SPiDUser *user = [[SPiDUser alloc] init];
    [user attachAccountRequestWithJwt:jwt completionHandler:completionHandler];
}

+ (SPiDJwt *)facebookJwtWithAppId:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate {
    NSString *aud = [NSString stringWithFormat:@"%@/api/2/signup_jwt", [SPiDClient sharedInstance].serverURL.absoluteString];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:appId forKey:@"iss"];
    [dictionary setValue:@"registration" forKey:@"sub"];
    [dictionary setValue:aud forKey:@"aud"];
    [dictionary setValue:expirationDate.description forKey:@"exp"];
    [dictionary setValue:@"facebook" forKey:@"token_type"];
    [dictionary setValue:facebookToken forKey:@"token_value"];
    SPiDJwt *jwt = [SPiDJwt jwtTokenWithDictionary:dictionary];
    return jwt;
}

+ (SPiDJwt *)attachFacebookJwtWithAppId:(NSString *)appId facebookToken:(NSString *)facebookToken expirationDate:(NSDate *)expirationDate {
    NSString *aud = [NSString stringWithFormat:@"%@/api/2/attach_jwt", [SPiDClient sharedInstance].serverURL.absoluteString];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:appId forKey:@"iss"];
    [dictionary setValue:@"attach" forKey:@"sub"];
    [dictionary setValue:aud forKey:@"aud"];
    [dictionary setValue:expirationDate.description forKey:@"exp"];
    [dictionary setValue:@"facebook" forKey:@"token_type"];
    [dictionary setValue:facebookToken forKey:@"token_value"];
    SPiDJwt *jwt = [SPiDJwt jwtTokenWithDictionary:dictionary];
    return jwt;
}

- (NSDictionary *)userPostDataWithEmail:(NSString *)email password:(NSString *)password {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:email forKey:@"email"];
    [data setValue:password forKey:@"password"];
    [data setValue:[[SPiDClient sharedInstance] authorizationURLWithQuery].absoluteString forKey:@"redirectUri"];
    return data;
}

- (NSDictionary *)userPostDataWithJwt:(SPiDJwt *)jwt {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    // TODO: should check for nil even though it should not happen!
    [data setValue:jwt.encodedJwtString forKey:@"jwt"];
    return data;
}

- (SPiDError *)validateEmail:(NSString *)email password:(NSString *)password {
    if (![SPiDUtils validateEmail:email]) {
                // TODO: reason:@"ValidationError"
        return [NSError spidOauth2ErrorWithCode:SPiDInvalidEmailAddressErrorCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The email address is invalid", @"error", nil]];
    } else if ([password length] < 8) {
        // TODO: reason:@"ValidationError"
        return [NSError spidOauth2ErrorWithCode:SPiDInvalidPasswordErrorCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Password needs to contain at least 8 letters", @"error", nil]];
    }
    return nil;
}

///---------------------------------------------------------------------------------------
/// @name Private Methods
///---------------------------------------------------------------------------------------

- (void)accountRequestWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSError *))completionHandler {
    NSDictionary *postBody = [self userPostDataWithEmail:email password:password];
    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:@"/signup" body:postBody completionHandler:^(SPiDResponse *response) {
        completionHandler([response error]);
    }];
    [request startRequestWithAccessToken];
}

- (void)accountRequestWithJwt:(SPiDJwt *)jwt completionHandler:(void (^)(NSError *))completionHandler {
    NSDictionary *postBody = [self userPostDataWithJwt:jwt];
    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:@"/signup_jwt" body:postBody completionHandler:^(SPiDResponse *response) {
        completionHandler([response error]);
    }];
    [request startRequestWithAccessToken];
}

- (void)attachAccountRequestWithJwt:(SPiDJwt *)jwt completionHandler:(void (^)(NSError *))completionHandler {
    NSDictionary *postBody = [self userPostDataWithJwt:jwt];
    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:@"/user/attach_jwt" body:postBody completionHandler:^(SPiDResponse *response) {
        completionHandler([response error]);
    }];
    [request startRequestWithAccessToken];
}

@end
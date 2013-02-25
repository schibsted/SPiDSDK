//
//  SPiDUser
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDUser.h"
#import "SPiDClient.h"
#import "SPiDAccessToken.h"
#import "SPiDError.h"
#import "SPiDResponse.h"
#import "SPiDTokenRequest.h"

@interface SPiDUser ()
- (void)accountRequestWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(SPiDError *))completionHandler;

@end

@implementation SPiDUser

+ (void)createAccountWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(SPiDError *response))completionHandler {
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
        SPiDRequest *clientTokenRequest = [SPiDTokenRequest clientTokenRequestWithCompletionHandler:^(SPiDError *error) {
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

- (NSDictionary *)userPostDataWithEmail:(NSString *)email password:(NSString *)password {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:email forKey:@"email"];
    [data setValue:password forKey:@"password"];
    [data setValue:[[SPiDClient sharedInstance] authorizationURLWithQuery].absoluteString forKey:@"redirectUri"];
    return data;
}

- (SPiDError *)validateEmail:(NSString *)email password:(NSString *)password {
    if (![SPiDUtils validateEmail:email]) {
        return [SPiDError oauth2ErrorWithCode:SPiDInvalidEmailAddressErrorCode reason:@"ValidationError" descriptions:[NSDictionary dictionaryWithObjectsAndKeys:@"The email address is invalid", @"error", nil]];
    } else if ([password length] < 8) {
        return [SPiDError oauth2ErrorWithCode:SPiDInvalidPasswordErrorCode reason:@"ValidationError" descriptions:[NSDictionary dictionaryWithObjectsAndKeys:@"Password needs to contain at least 8 letters", @"error", nil]];
    }
    return nil;
}

///---------------------------------------------------------------------------------------
/// @name Private Methods
///---------------------------------------------------------------------------------------

- (void)accountRequestWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(SPiDError *))completionHandler {
    NSDictionary *postBody = [self userPostDataWithEmail:email password:password];
    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:@"/signup" body:postBody completionHandler:^(SPiDResponse *response) {
        completionHandler([response error]);
    }];
    [request startRequestWithAccessToken];
}

@end
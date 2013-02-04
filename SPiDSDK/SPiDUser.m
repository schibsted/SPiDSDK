//
//  SPiDUser
//  SPiDSDK
//
//  Created by mikaellindstrom on 2/3/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDUser.h"
#import "SPiDClient.h"
#import "SPiDAccessToken.h"
#import "NSError+SPiDError.h"
#import "SPiDResponse.h"
#import "SPiDTokenRequest.h"


@implementation SPiDUser

- (void)createAccountWithEmail:(NSString *)email andPassword:(NSString *)password andCompletionHandler:(void (^)(NSError *response))completionHandler {
    // Validate email and password
    NSError *validationError = [self validateEmail:email andPassword:password];
    if (validationError) {
        completionHandler(validationError);
    }
    // Get client token
    SPiDAccessToken *accessToken = [[SPiDClient sharedInstance] getAccessToken];
    if (accessToken == nil || !accessToken.isClientToken) {
        SPiDDebugLog(@"No client token found, trying to request one");
        SPiDRequest *clientTokenRequest = [SPiDTokenRequest clientTokenRequestWithCompletionHandler:^(NSError *error) {
            if (error) {
                completionHandler(error);
            } else {
                SPiDDebugLog(@"Client token received, creating account");
                [self accountRequestWithEmail:email andPassword:password andCompletionHandler:completionHandler];
            }
        }];
        [clientTokenRequest startRequest];
    } else {
        SPiDDebugLog(@"Client token found, creating account");
        [self accountRequestWithEmail:email andPassword:password andCompletionHandler:completionHandler];
    }
}


- (void)accountRequestWithEmail:(NSString *)email andPassword:(NSString *)password andCompletionHandler:(void (^)(NSError *))completionHandler {
    NSDictionary *postBody = [self userTokenPostDataWithUsername:email andPassword:password];
    SPiDRequest *request = [SPiDRequest postRequestWithPath:@"/api/2/user" andHTTPBody:postBody andCompletionHandler:^(SPiDResponse *response) {
        completionHandler([response error]);
    }];
    [request startRequestWithAccessToken:[[SPiDClient sharedInstance] getAccessToken]];
}

- (NSDictionary *)userTokenPostDataWithUsername:(NSString *)username andPassword:(NSString *)password {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:username forKey:@"email"];
    [data setValue:password forKey:@"password"];
    return data;
}

- (NSError *)validateEmail:(NSString *)email andPassword:(NSString *)password {
    if (![SPiDUtils validateEmail:email]) {
        return [NSError oauth2ErrorWithCode:SPiDInvalidEmailAddressErrorCode description:@"ValidationError" reason:@"The email address is invalid"];
    } else if ([password length] < 8) {
        return [NSError oauth2ErrorWithCode:SPiDInvalidPasswordErrorCode description:@"ValidationError" reason:@"Password needs to contain at least 8 letters"];
    }
    return nil;
}

@end
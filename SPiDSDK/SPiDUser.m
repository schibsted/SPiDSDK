//
//  SPiDUser
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDUser.h"
#import "SPiDClient.h"
#import "SPiDAccessToken.h"
#import "NSError+SPiDError.h"
#import "SPiDResponse.h"
#import "SPiDTokenRequest.h"

@interface SPiDUser ()
- (void)accountRequestWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSError *))completionHandler;

@end

@implementation SPiDUser

+ (void)createAccountWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSError *response))completionHandler {
    SPiDUser *user = [[SPiDUser alloc] init];
    // Validate email and password
    NSError *validationError = [user validateEmail:email password:password];
    if (validationError) {
        completionHandler(validationError);
    }
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

- (NSDictionary *)userPostDataWithEmail:(NSString *)email password:(NSString *)password {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:email forKey:@"email"];
    [data setValue:password forKey:@"password"];
    return data;
}

- (NSError *)validateEmail:(NSString *)email password:(NSString *)password {
    if (![SPiDUtils validateEmail:email]) {
        return [NSError oauth2ErrorWithCode:SPiDInvalidEmailAddressErrorCode description:@"ValidationError" reason:@"The email address is invalid"];
    } else if ([password length] < 8) {
        return [NSError oauth2ErrorWithCode:SPiDInvalidPasswordErrorCode description:@"ValidationError" reason:@"Password needs to contain at least 8 letters"];
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

@end
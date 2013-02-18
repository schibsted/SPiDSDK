//
//  SPiDJwt
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDJwt.h"
#import "SPiDClient.h"
#import "NSData+Base64.h"
#import "NSString+Crypto.h"

@interface SPiDJwt ()
/* Validates the JWT token

 @return Return true of the JWT token is valid
*/
- (BOOL)validateJwt;
@end

@implementation SPiDJwt

+ (id)jwtTokenWithDictionary:(NSDictionary *)dictionary {
    SPiDJwt *jwtToken = [[SPiDJwt alloc] init];
    jwtToken.iss = [dictionary objectForKey:@"iss"];
    jwtToken.sub = [dictionary objectForKey:@"sub"];
    jwtToken.aud = [dictionary objectForKey:@"aud"];
    jwtToken.exp = [dictionary objectForKey:@"exp"];
    jwtToken.tokenType = [dictionary objectForKey:@"token_type"];
    jwtToken.tokenValue = [dictionary objectForKey:@"token_value"];
    return jwtToken;
}

- (NSString *)encodedJwtString {
    if (![self validateJwt]) {
        return nil;
    }
    if ([[SPiDClient sharedInstance] sigSecret] == nil) {
        SPiDDebugLog(@"No signing secret found, cannot use JWT");
        return nil;
    }

    NSError *jsonError;
    NSDictionary *headerDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:JSON_WEB_ALGORITHM_HS256, @"alg",
                                                                                  JSON_WEB_TOKEN_TYP_JWT, @"typ", nil];
    NSData *headerJson = [NSJSONSerialization dataWithJSONObject:headerDictionary options:(NSJSONWritingOptions) 0 error:&jsonError];
    NSString *header = [headerJson base64EncodedString];
    if (jsonError != nil) {
        SPiDDebugLog(@"Error encoding JWT header");
        return nil;
    }

    NSDictionary *claimDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.iss, @"iss",
                                                                                 self.sub, @"sub",
                                                                                 self.aud, @"aud",
                                                                                 self.exp, @"exp",
                                                                                 self.tokenType, @"token_type",
                                                                                 self.tokenValue, @"token_value",
                                                                                 nil];

    NSData *claimJson = [NSJSONSerialization dataWithJSONObject:claimDictionary options:(NSJSONWritingOptions) 0 error:&jsonError];
    NSString *claim = [claimJson base64EncodedString];
    if (jsonError != nil) {
        SPiDDebugLog(@"Error encoding JWT claim");
        return nil;
    }

    NSString *payload = [NSString stringWithFormat:@"%@.%@", header, claim];
    NSString *signature = [payload hmacSHA256withKey:[[SPiDClient sharedInstance] sigSecret]];
    return [NSString stringWithFormat:@"%@.%@.%@", header, claim, signature];
}

- (BOOL)validateJwt {
    if (self.iss == nil) {
        SPiDDebugLog(@"JWT is missing value for iss");
        return NO;
    }
    if (self.sub == nil) {
        SPiDDebugLog(@"JWT is missing value for sub");
        return NO;
    }
    if (self.aud == nil) {
        SPiDDebugLog(@"JWT is missing value for aud");
        return NO;
    }
    if (self.exp == nil) {
        SPiDDebugLog(@"JWT is missing value for exp");
        return NO;
    }
    if (self.tokenType == nil) {
        SPiDDebugLog(@"JWT is missing value for token type");
        return NO;
    }
    if (self.tokenValue == nil) {
        SPiDDebugLog(@"JWT is missing value for token value");
        return NO;
    }
    return YES;
}

@end
//
//  SPiDKeychainWrapper.h
//  SPiDSDK
//
//  Created by mikaellindstrom on 9/27/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDKeychainWrapper.h"

@interface SPiDKeychainWrapper ()
+ (NSString *)serviceNameForSPiD;
//+ basicquery
@end

// Note that all keychain items are available in the iPhone simulator to all apps since the application is not signed!
@implementation SPiDKeychainWrapper

#pragma mark Public methods

+ (SPiDAccessToken *)getAccessTokenFromKeychainForIdentifier:(NSString *)identifier; {
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id) kSecClassGenericPassword forKey:(__bridge id) kSecClass];

    // set unique identification
    [query setObject:identifier forKey:(__bridge id) kSecAttrGeneric];
    [query setObject:identifier forKey:(__bridge id) kSecAttrAccount];
    [query setObject:[self serviceNameForSPiD] forKey:(__bridge id) kSecAttrService];

    // search attributes
    [query setObject:(__bridge id) kCFBooleanTrue forKey:(__bridge id) kSecMatchLimitOne];
    [query setObject:(__bridge id) kCFBooleanTrue forKey:(__bridge id) kSecReturnData];

    CFTypeRef cfData = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, &cfData);
    if (status == noErr) {
        NSData *result = (__bridge_transfer NSData *) cfData;
        SPiDAccessToken *accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:result];
        return accessToken;
    } else {
        //NSAssert(status == errSecItemNotFound, @"Error reading from keychain");
        return nil;
    }
}

+ (BOOL)storeInKeychainAccessTokenWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id) kSecClassGenericPassword forKey:(__bridge id) kSecClass];

    // set unique identification
    [query setObject:identifier forKey:(__bridge id) kSecAttrGeneric];
    [query setObject:identifier forKey:(__bridge id) kSecAttrAccount];
    [query setObject:[self serviceNameForSPiD] forKey:(__bridge id) kSecAttrService];

    // add data
    [query setObject:data forKey:(__bridge id) kSecValueData];

    OSStatus status = SecItemAdd((__bridge CFDictionaryRef) query, NULL);
    if (status == errSecSuccess) {
        return YES;
    } else if (status == errSecDuplicateItem) {
        return [self updateAccessTokenInKeychainWithValue:accessToken forIdentifier:identifier];
    } else {
        // TODO: should we throw error instead?
        return NO;
    }
}

+ (BOOL)updateAccessTokenInKeychainWithValue:(SPiDAccessToken *)accessToken forIdentifier:(NSString *)identifier {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
    SPiDAccessToken *test = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableDictionary *searchQuery = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *updateQuery = [[NSMutableDictionary alloc] init];
    [searchQuery setObject:(__bridge id) kSecClassGenericPassword forKey:(__bridge id) kSecClass];

    // set unique identification
    [searchQuery setObject:identifier forKey:(__bridge id) kSecAttrGeneric];
    [searchQuery setObject:identifier forKey:(__bridge id) kSecAttrAccount];
    [searchQuery setObject:[self serviceNameForSPiD] forKey:(__bridge id) kSecAttrService];

    // add data
    [updateQuery setObject:data forKey:(__bridge id) kSecValueData];

    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef) searchQuery, (__bridge CFDictionaryRef) updateQuery);
    if (status == errSecSuccess) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)removeAccessTokenFromKeychainForIdentifier:(NSString *)identifier {
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id) kSecClassGenericPassword forKey:(__bridge id) kSecClass];

    // set unique identification
    [query setObject:identifier forKey:(__bridge id) kSecAttrGeneric];
    [query setObject:identifier forKey:(__bridge id) kSecAttrAccount];
    [query setObject:[self serviceNameForSPiD] forKey:(__bridge id) kSecAttrService];

    OSStatus status = SecItemDelete((__bridge CFDictionaryRef) query);
    NSAssert(status == noErr, @"Error deleting item to keychain");
}

#pragma mark Private methods

+ (NSString *)serviceNameForSPiD {
    NSString *appName = [[NSBundle mainBundle] bundleIdentifier];
    return [NSString stringWithFormat:@"%@-SPiD", appName];
}

@end
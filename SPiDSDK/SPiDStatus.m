//
//  SPiDStatus
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDStatus.h"
#import "NSData+Base64.h"

//#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation SPiDStatus

+ (void)runStatusRequest {
    SPiDRequest *statusRequest = [SPiDStatus statusRequestWithCompletionHandler:^(SPiDResponse *response) {
        SPiDDebugLog(@"Received status response: %@", response.rawJSON);
    }];
    if ([SPiDClient sharedInstance].isAuthorized && ![SPiDClient sharedInstance].isClientToken) {
        [statusRequest startRequestWithAccessToken];
    } else {
        [statusRequest start];
    }
}

+ (SPiDRequest *)statusRequestWithCompletionHandler:(void (^)(SPiDResponse *response))completionHandler {
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setValue:[UIDevice currentDevice].name forKey:@"deviceName"];
    [body setValue:[UIDevice currentDevice].model forKey:@"deviceModel"];
    [body setValue:[SPiDStatus orientationToString:[UIDevice currentDevice].orientation] forKey:@"deviceOrientation"];

    [body setValue:[UIDevice currentDevice].systemName forKey:@"systemName"];
    [body setValue:[UIDevice currentDevice].systemVersion forKey:@"systemVersion"];

    [body setValue:[SPiDStatus applicationId] forKey:@"applicationId"];
    [body setValue:[SPiDStatus vendorId] forKey:@"vendorId"];

    [body setValue:SPID_IOS_SDK_VERSION_STRING forKey:@"sdkVersion"];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [body setValue:[infoDictionary objectForKey:@"CFBundleDisplayName"] forKey:@"bundleDisplayName"];
    [body setValue:[infoDictionary objectForKey:@"CFBundleVersion"] forKey:@"bundleMinorVersion"];
    [body setValue:[infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"bundleMajorVersion"];
    [body setValue:[NSBundle mainBundle].bundleIdentifier forKey:@"bundleIdentifier"];

    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:body options:(NSJSONWritingOptions) 0 error:&error];
    NSString *jsonString = [json base64EncodedString];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:jsonString forKey:@"fp"];
    [dict setValue:[[SPiDClient sharedInstance] clientID] forKey:@"clientId"];

    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:@"/status" body:dict completionHandler:completionHandler];
    return request;
}

+ (NSString *)vendorId {
    NSString *vendorID = nil;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return vendorID;
}

+ (NSString *)applicationId {
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"test"];
    if (!uuid) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        uuid = (__bridge_transfer NSString *) CFUUIDCreateString(NULL, uuidRef);
        CFRelease((CFTypeRef) uuidRef);

        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"test"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return uuid;
}

+ (NSString *)spidUserAgent {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *bundleMinorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *deviceModel = [UIDevice currentDevice].model;
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    
    return [NSString stringWithFormat:@"%@/%@ SPiDIOSSDK/%@ %@/%@", bundleDisplayName, bundleMinorVersion, SPID_IOS_SDK_VERSION_STRING, deviceModel, systemVersion];
}

+ (NSString *)orientationToString:(UIDeviceOrientation)orientation {
    NSString *result = nil;

    switch (orientation) {
        case UIDeviceOrientationPortrait:
            result = @"DeviceOrientationPortrait";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            result = @"DeviceOrientationPortraitUpsideDown";
            break;
        case UIDeviceOrientationLandscapeLeft:
            result = @"DeviceOrientationLandscapeLeft";
            break;
        case UIDeviceOrientationLandscapeRight:
            result = @"DeviceOrientationLandscapeRight";
            break;
        case UIDeviceOrientationFaceUp:
            result = @"DeviceOrientationFaceUp";
            break;
        case UIDeviceOrientationFaceDown:
            result = @"DeviceOrientationFaceDown";
            break;
        case UIDeviceOrientationUnknown:
        default:
            result = @"DeviceOrientationUnknown";
            break;
    }
    return result;
}

@end
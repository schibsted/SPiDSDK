//
//  SPiDStatus
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDStatus.h"
#import "NSData+Base64.h"

#if TARGET_OS_WATCH
    #import <WatchKit/WatchKit.h>
#else
    #import <UIKit/UIDevice.h>
#endif

@interface SPiDStatus (orientation)

+ (NSString *)orientationString;

@end

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
#if TARGET_OS_IOS || TARGET_OS_TV
    [body setValue:[UIDevice currentDevice].name forKey:@"deviceName"];
    [body setValue:[UIDevice currentDevice].model forKey:@"deviceModel"];
    [body setValue:[SPiDStatus orientationString] forKey:@"deviceOrientation"];

    [body setValue:[UIDevice currentDevice].systemName forKey:@"systemName"];
    [body setValue:[UIDevice currentDevice].systemVersion forKey:@"systemVersion"];
#endif

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
    NSString *jsonString = [json sp_base64EncodedString];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:jsonString forKey:@"fp"];
    [dict setValue:[[SPiDClient sharedInstance] clientID] forKey:@"clientId"];

    SPiDRequest *request = [SPiDRequest apiPostRequestWithPath:@"/status" body:dict completionHandler:completionHandler];
    return request;
}

+ (NSString *)vendorId {
    NSString *vendorID = nil;
#if !TARGET_OS_WATCH
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
#endif
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
    
#if TARGET_OS_WATCH
    NSString *deviceModel = [WKInterfaceDevice currentDevice].model;
    NSOperatingSystemVersion version = [NSProcessInfo processInfo].operatingSystemVersion;
    NSString *systemVersion = [NSString stringWithFormat:@"%zd.%zd.%zd", version.majorVersion, version.minorVersion, version.patchVersion];
#else
    NSString *deviceModel = [UIDevice currentDevice].model;
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
#endif
    
    return [NSString stringWithFormat:@"%@/%@ SPiDIOSSDK/%@ %@/%@", bundleDisplayName, bundleMinorVersion, SPID_IOS_SDK_VERSION_STRING, deviceModel, systemVersion];
}

@end

@implementation SPiDStatus (orientation)

+ (NSString *)orientationString {
#if TARGET_OS_IOS
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
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
#else
    return @"DeviceOrientationUnknown";
#endif
}

@end

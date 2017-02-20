//
//  NSDictionary+Test.m
//  SPiDSDK
//
//  Created by Joakim Gyllström on 2017-02-15.
//

#import "NSDictionary+Test.h"
#import "SPiDSDKTests.h"

@implementation NSDictionary (Test)

+ (NSDictionary *)sp_JSONStubWithName:(NSString *)stubName {
    NSString *path = [[NSBundle bundleForClass:[SPiDSDKTests class]] pathForResource:stubName ofType:@"json"];

    NSData *data = [NSData dataWithContentsOfFile:path];
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

@end

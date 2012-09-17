//
// Created by mikaellindstrom on 9/17/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SPiDClient.h"

@interface SPiDRequest : NSObject <NSURLConnectionDelegate>

@property(strong, nonatomic) NSURL *url;
@property(strong, nonatomic) NSString *httpMethod;
@property(copy) void (^completionHandler)(NSDictionary *dict);
@property(strong, nonatomic) NSMutableData *receivedData;

- (void)doAuthenticatedSPiDGetRequestWithURL:(NSURL *)url;

- (void)doAuthenticatedMeRequestWithCompletionHandler:(void (^)(NSDictionary *dict))completionHandler;

- (void)doAuthenticatedLogoutRequestWithCompletionHandler:(void (^)(NSDictionary *dict))completionHandler;

@end
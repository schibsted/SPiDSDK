//
// Created by mikaellindstrom on 9/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "SPiDConstants.h"
#import "SPiDClient.h"
#import "SPiDAccessToken.h"

// Not accessible outside SDK
typedef void (^SPiDInternalAuthorizationCompletionHandler)(SPiDAccessToken *accessToken, NSError *error);

@interface SPiDAuthorizationRequest : NSObject <NSURLConnectionDelegate> {
@private
    NSString *code;
    NSMutableData *receivedData;

    SPiDInternalAuthorizationCompletionHandler completionHandler;
}

- (id)initWithCompletionHandler:(SPiDInternalAuthorizationCompletionHandler)handler;

- (void)authorize;

- (BOOL)handleOpenURL:(NSURL *)url;

@end
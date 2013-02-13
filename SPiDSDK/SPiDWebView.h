//
//  SPiDWebView
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SPiDWebView : UIWebView <UIWebViewDelegate>

@property(nonatomic) BOOL isPending;
@property(strong, nonatomic) NSURL *requestURL;
@property(nonatomic, copy) void (^completionHandler)(NSError *);


/** Creates a authorization WebView.

 @return The new WebView
*/
+ (SPiDWebView *)authorizationWebViewWithCompletionHandler:(void (^)(NSError *))completionHandler;

/** Creates a registration WebView

 @return The new WebView
*/
+ (SPiDWebView *)signupWebViewWithCompletionHandler:(void (^)(NSError *))completionHandler;

/** Creates a lost password WebView
*
 @return The new WebView
*/
+ (SPiDWebView *)forgotPasswordWebViewWithCompletionHandler:(void (^)(NSError *))completionHandler;

@end
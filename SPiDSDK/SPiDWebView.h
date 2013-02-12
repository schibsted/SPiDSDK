//
//  SPiDWebView
//  SPiDSDK
//
//  Created by mikaellindstrom on 2/6/13.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SPiDWebView : UIWebView <UIWebViewDelegate>

@property(nonatomic) BOOL isPending;
@property(strong, nonatomic) NSURL *requestURL;
@property(nonatomic, copy) void (^completionHandler)(NSString *code, NSError *);


/** Creates a authorization WebView.

 @return The new WebView
*/
+ (SPiDWebView *)authorizationWebViewWithCompletionHandler:(void (^)(NSString *code, NSError *))completionHandler;

/** Creates a registration WebView

 @return The new WebView
*/
+ (SPiDWebView *)signupWebViewWithCompletionHandler:(void (^)(NSString *code, NSError *))completionHandler;

/** Creates a lost password WebView
*
 @return The new WebView
*/
+ (SPiDWebView *)forgotPasswordWebViewWithCompletionHandler:(void (^)(NSString *code, NSError *))completionHandler;

@end
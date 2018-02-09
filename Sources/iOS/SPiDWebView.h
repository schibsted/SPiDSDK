//
//  SPiDWebView
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

@import Foundation;
@import UIKit;

/** WebView for handling authorization against SPiD. */

@interface SPiDWebView : UIWebView <UIWebViewDelegate>

///---------------------------------------------------------------------------------------
/// @name Properties
///---------------------------------------------------------------------------------------

/** */
@property(nonatomic) BOOL isPending;

/** */
@property(strong, nonatomic) NSURL *requestURL;

/** */
@property(nonatomic, copy) void (^completionHandler)(NSError *);

///---------------------------------------------------------------------------------------
/// @name Public methods
///---------------------------------------------------------------------------------------

/** Creates a authorization WebView.

 @param completionHandler Called after authorization is completed
 @return The new WebView
*/
+ (instancetype)authorizationWebViewWithCompletionHandler:(void (^)(NSError *))completionHandler;

/** Creates a registration WebView

 @param completionHandler Called after signup is completed
 @return The new WebView
*/
+ (instancetype)signupWebViewWithCompletionHandler:(void (^)(NSError *))completionHandler;

/** Creates a forgot password WebView

 @param completionHandler Called after forgot password is completed
 @return The new WebView
*/
+ (instancetype)forgotPasswordWebViewWithCompletionHandler:(void (^)(NSError *))completionHandler;

@end

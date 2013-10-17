//
//  SPiDWebView
//  SPiDSDK
//
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SPiDError;

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
+ (id)authorizationWebViewWithCompletionHandler:(void (^)(NSError *))completionHandler;

/** Creates a registration WebView

 @param completionHandler Called after signup is completed
 @return The new WebView
*/
+ (id)signupWebViewWithCompletionHandler:(void (^)(NSError *))completionHandler;

/** Creates a forgot password WebView

 @param completionHandler Called after forgot password is completed
 @return The new WebView
*/
+ (id)forgotPasswordWebViewWithCompletionHandler:(void (^)(NSError *))completionHandler;

@end
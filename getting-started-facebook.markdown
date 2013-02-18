---
title: Getting started with Facebook
layout: default
---
Setting up Facebook
===================
Following the SPiD 2.7 release, login and signup through Facebook is now supported.
The SPiD SDK uses the Facebook SDK to enable login. The currently supported version of the Facebook SDK is 3.1.
This also requires a FacebookApp to be setup for your application.

For information about downloading the SDK, adding it to the project and creating a Facebook app see [Facebook getting started with iOS](https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/3.1/ "Facebook getting started with iOS").

The next step is to add the login action and handler which is described in detail at [Facebook authentication](https://developers.facebook.com/docs/tutorials/ios-sdk-tutorial/authenticate/ "Facebook authentication").

First we define the callback for when the session state changes for Facebook. If the session is successfully opened we call the local method called `userTokenRequestWithFacebookTokenSession:`.
{% highlight objectivec %}
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen:
            if (error) {
                // Something went wrong with the Facebook login
            } else {
                // We now have a valid facebook session and can get the token from [FBSession activeSession].accessToken;
                [self userTokenRequestWithFacebookTokenSession:[FBSession activeSession]];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
}
{% endhighlight %}

We also need to define a method to open the Facebook session with the right permissions. Currently the only special permission SPiD needs is the email address.
`openActiveSessionWithReadPermissions:` will first try to access the Facebook credentials in iOS, if that fails it will try the FacebookApp and lastly do a browser redirect if the other fails.
{% highlight objectivec %}
- (BOOL)openSessionFacebookSession {
    NSArray *permissions = [[NSArray alloc] initWithObjects:
            @"email",
            nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session,
                                                 FBSessionState state,
                                                 NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}
{% endhighlight %}

Lastly we need to handle callbacks to the application, this is only used when the FacebookApp or browser redirect is used.
{% highlight objectivec %}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBSession.activeSession handleOpenURL:url];
}
{% endhighlight %}

Setting up SPiD
===============
Since the JWT token sent from the app is signed, a sign secret need to be set. This is preferably done right after the setup of the `SPiDClient` with the following code:
{% highlight objectivec %}
    [[SPiDClient sharedInstance] setSignSecret:@"your-sign-secret"];
{% endhighlight %}

Next we create the method that will be called when the Facebook session is opened. This sends a user token request with the Facebook token encoded as a JSON Web Token.
Note that if the user does not exist, the user will be created using the email address from the Facebook account.
{% highlight objectivec %}
- (void)userTokenRequestWithFacebookToken:(FBSession *)facebookSession {
    SPiDTokenRequest *request = [SPiDTokenRequest userTokenRequestWithFacebookAppID:facebookSession.appID
                                                                      facebookToken:facebookSession.accessToken
                                                                     expirationDate:facebookSession.expirationDate
                                                                  completionHandler:^(NSError *tokenError) {
                                                                      if (tokenError) {
                                                                          // Something went wrong
                                                                      } else {
                                                                          // Successfully logged in to SPiD!
                                                                      }
                                                                  }];
    [request startRequest];
}
{% endhighlight %}

That´s it, now all we need to do is to call `openSessionFacebookSession:` and the login process will start och hopefully be successfull.

See the SPiDFacebookExample in the SDK for a simple application with facebook login.

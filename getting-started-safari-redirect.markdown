---
title: Getting started with Safari redirect
layout: default
---
Safari redirect
===============
The authorization process for Safari redirect is in two steps, in the first we login to SPiD in Safari and then receives a code. If the user already has logged into SPiD, Safari has a cookie that will login the user and redirect back to the app.
The second step is to exchange the code for a access token which can be used to make requests against SPiD.
Both these steps are done automatically and the client will only have to use the method `browserRedirectAuthorizationWithCompletionHandler` method as seen below.

{% highlight objectivec %}
// Try to login
[[SPiDClient sharedInstance] browserRedirectAuthorizationWithCompletionHandler:^(NSError *error) {
    if (!error) {
        // Successfully logged in to SPiD!
    } else if ([error code] == SPiDUserAbortedLogin) {
        // user aborted login and pressed back to app
    } else {
        // something went wrong and we need to check what error we received
    }
}];
{% endhighlight %}

When the login completes in Safari the following code the was setup in "Setting up SPiD" will be called
{% highlight objectivec %}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // This returns YES if SPiD SDK handled the URL
    return [[SPiDClient sharedInstance] handleOpenURL:url];
}
{% endhighlight %}

This will complete the login and call the completion handler specified in `authorizationRequestWithCompletionHandler`. You can then start making [API requests](using-spid-requests.html "API requests").

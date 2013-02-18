---
title: Setting up SPiD
layout: default
---
Setting up SPiD
===============
This will provide a small introduction on how to setup the SPiD SDK for your iOS application.

The all SDK interactions is centered around `SPiDClient` which is a singleton. All client calls should go through this class.

The SDK needs to be setup with parameters received from SPiD which are _client ID_ and _client secret_ and _SPiD server_. The SDK also need to know the app URL scheme.
App URL Scheme and SPiD server are used for generating requests and redirect URLs, they can be overridden by using the properties of `SPiDClient` if needed.
The setup should be done after the app has loaded, preferably in `application:didFinishLaunchingWithOptions:` method in the app delegate.

The following code is used to setup the `SPiDClient`
{% highlight objectivec %}
[SPiDClient setClientID:@"clientID"
		andClientSecret:@"clientSecret"
		andAppURLScheme:@"urlScheme"
		   andServerURL:[NSURL URLWithString:@"www.spid.com"]];
{% endhighlight %}

{% highlight objectivec %}
if ([[SPiDClient sharedInstance] isAuthorized]) {
    // Access token was saved in keychain
} else {
    // Not logged in
}
{% endhighlight %}

Since there are times when there are redirects to the app this must be handled. One example is opening the app from Safari.
This is done by implementing the `application:openURL:sourceApplication:annotation:` method of the app delegate to receive the response from Safari and pass to over the the SPiD SDK.

{% highlight objectivec %}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // This returns YES if SPiD SDK handled the URL
    return [[SPiDClient sharedInstance] handleOpenURL:url];
}
{% endhighlight %}

The actual authorization can be done with either [Safari redirect](getting-started-safari-redirect.html "Safari redirect") or [UIWebView](getting-started-uiwebview.html "UIWebView").
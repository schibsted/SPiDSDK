---
title: Getting started with UIWebView
layout: default
---
UIWebView
=========
The authorization process for UIWebView two steps, in the first we login to SPiD in a UIWebView and then receives a code. The code is then exchanged for a access token which can be used to make requests against SPiD.
Both these steps are done automatically and the client will only have to use the method `webViewAuthorizationWithCompletionHandler` method as seen below.
{% highlight objectivec %}
  UIWebView *webView = [[SPiDClient sharedInstance] webViewAuthorizationWithCompletionHandler:^(NSError *error) {
        if (!error) {
            // successfully logged in to SPiD and have a access token
            // we can now call API requests
        } else if ([error code] == SPiDUserAbortedLogin) {
            // user aborted login and pressed back to app
        } else {
            // something went wrong and we need to check what error we received
        }
    }];
{% endhighlight %}

If the user should go directly to the registration or lost password pages the following methods can be used.
{% highlight objectivec %}
UIWebView *webView = [[SPiDClient sharedInstance] webViewRegistrationWithCompletionHandler:^(NSError *error) {  }];
{% endhighlight %}

{% highlight objectivec %}
UIWebView *webView = [[SPiDClient sharedInstance] webViewLostPasswordWithCompletionHandler:^(NSError *error) {  }];
{% endhighlight %}

After the login has been completed and the completion handler has been executed you can start making [API requests](using-spid-requests.html "API requests").
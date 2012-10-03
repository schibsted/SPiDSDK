Getting started
==========

This guide will provide a small introduction to getting started with the SPiD SDK for iOS.

The SDK is centered around a instance of `SPiDClient` which is a singleton, all access to SPiD goes through this instance.
Before use the client needs to be setup with the required variable which are _client ID_ and _client secret_ with are provided by SPiD, the _appURLScheme_ and finally the address to the SPiD server.
This should be done when starting the application, eg in the app delegate.

<pre><code>[[SPiDClient sharedInstance] setClientID:@"clientID" andClientSecret:@"clientSecret" andAppURLScheme:@"urlScheme" andServerURL:[NSURL URLWithString:@"www.spid.com"]];</code></pre>

When the singleton is loaded the first time the SDK will try to load a access token from the keychain. If this is successful user will not have to be redirected to Safari.
If not we have to redirect to Safari for the user to login.

The authorization process is in two steps, in the first we login to SPiD in Safari and then receives a code. If the user already has logged into SPiD, Safari has a cookie that will login the user and redirect back to the app.
The second step is to exchange the code for a access token which can be used to make requests against SPiD. To login to SPiD we simply call the `authorizationRequestWithCompletionHandler` method as seen below.


<pre><code>// Check if we already have a access token in the keychain
if (![[SPiDClient sharedInstance] isAuthorizedIn]) {
    // Try to login
    [[SPiDClient sharedInstance] authorizationRequestWithCompletionHandler:^(NSError *error) {
        if (error) {
            // something went wrong and we need to check what error we received
        } else {
            // We have successfully logged in to SPiD and have a access token
        }
    }];
}
</code></pre>

We also need to configure the `application:openURL:sourceApplication:annotation:` method to receive the response from Safari and pass to over the the SPiD SDK. This can be done in the app delegate as seen below.

<pre><code>
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // This returns YES if SPiD SDK handled the URL
    return [[SPiDClient sharedInstance] handleOpenURL:url];
}
</code></pre>

After this we can start using the SPiD API to make requests.

<pre><code>// Try to fetch the "me" object
[[SPiDClient sharedInstance] meRequestWithCompletionHandler:^(SPiDResponse *response) {
    if ([response error]) {
        // something went wrong and we need to check what error we received
    } else {
        NSLog(@"The raw response", [response rawJSON]);
    }
}];
</code></pre>
Getting started
==========

This guide will provide a small introduction to getting started with the SPiD SDK for iOS.

The all SDK interactions is centered around `SPiDClient` which is a singleton. All client calls should go through this class.

The SDK needs to be setup with parameters received from SPiD which are _client ID_ and _client secret_ and _SPiD server_. The SDK also need to know the app URL scheme.
App URL Scheme and SPiD server are used for generating requests and redirect URLs, they can be overridden by using the properties of `SPiDClient`if needed.
The setup should be done after the app has loaded, preferably in `application:didFinishLaunchingWithOptions:` method in the app delegate.

The following code is used to setup the `SPiDClient`
<pre><code>[[SPiDClient sharedInstance] setClientID:@"clientID" andClientSecret:@"clientSecret" andAppURLScheme:@"urlScheme" andServerURL:[NSURL URLWithString:@"www.spid.com"]];</code></pre>

When the singleton is accessed the first time the SDK will try to load a access token from the keychain. If this is successful user will not have to be redirected to Safari.

The authorization process is in two steps, in the first we login to SPiD in Safari and then receives a code. If the user already has logged into SPiD, Safari has a cookie that will login the user and redirect back to the app.
The second step is to exchange the code for a access token which can be used to make requests against SPiD.
Both these steps are done automatically and the client will only have to use the method `authorizationRequestWithCompletionHandler` method as seen below.

<pre><code>// Check if we already have a access token in the keychain
if (![[SPiDClient sharedInstance] isAuthorized]) {
    // Try to login
    [[SPiDClient sharedInstance] authorizationRequestWithCompletionHandler:^(NSError *error) {
        if (error) {
            // something went wrong and we need to check what error we received
        } else {
            // successfully logged in to SPiD and have a access token
            // we can now call API requests
        }
    }];
}
</code></pre>

Since we redirect the user to Safari we need to handle URL redirects back to the app. This is done by implementing the `application:openURL:sourceApplication:annotation:` method of the app delegate
to receive the response from Safari and pass to over the the SPiD SDK.

<pre><code>
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // This returns YES if SPiD SDK handled the URL
    return [[SPiDClient sharedInstance] handleOpenURL:url];
}
</code></pre>

The app can now login to SPiD and make API requests, for example the following code gets the logged in user object.

<pre><code>// Try to fetch the "me" object
[[SPiDClient sharedInstance] getUserRequestWithCurrentUserAndCompletionHandler:^(SPiDResponse *response) {
    if ([response error]) {
        // something went wrong and we need to check what error we received
    } else {
        NSLog(@"The raw response", [response rawJSON]);
    }
}];
</code></pre>

The request returns a `SPiDResponse` object. Before trying to use the message or rawJSON property the client should check for errors using the error property.
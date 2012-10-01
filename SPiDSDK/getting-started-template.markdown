Getting started
==========

This guide will provide a small introduction to getting started with the SPiD SDK.

The SDK is centered around a instance of `SPiDClient` which is a singleton, all access to SPiD goes through this instance.
Before use the client needs to be setup with the required variable which are _client ID_ and _client secret_ with are provided by SPiD, the _appURLScheme_ and finally the address to the SPiD server.

<pre><code>[[SPiDClient sharedInstance] setClientID:@"clientID" andClientSecret:@"clientSecret" andAppURLScheme:@"urlScheme" andSPiDURL:[NSURL URLWithString:@"www.spid.com"]];</code></pre>

When the singleton is loaded the first time the SDK will try to load a access token from the keychain. If this is successful user will not have to be redirected to Safari.

<pre><code>// Check if we already have a access token in the keychain
if (![[SPiDClient sharedInstance] isLoggedIn]) {
    // Try to login
    [];
}
</code></pre>
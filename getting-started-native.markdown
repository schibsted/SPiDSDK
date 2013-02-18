---
title: Getting started with Native
layout: default
---
Native login
============
Following the SPiD 2.7 release (2.7.1 for signup), native app flow is now supported.

The native login flow is implemented using the `SPiDTokenRequest`. Note that validation is performed on the username and password to ensure that it is a valid email and that the password atleast 8 characters long.
{% highlight objectivec %}
- (void)loginWithEmail:(NSString *)email password:(NSString *)password {
    SPiDTokenRequest *tokenRequest = [SPiDTokenRequest userTokenRequestWithUsername:email password:password completionHandler:^(NSError *error) {
        if (error == nil) {
            // Successfully logged in to SPiD!
        } else if ([error code] == SPiDOAuth2UnverifiedUserErrorCode) {
            // Unverified user, please check your email
        } else if ([error code] == SPiDOAuth2InvalidUserCredentialsErrorCode) {
            // Invalid email and/or password
        } else {
            // Something went wrong
        }
    }];
    [tokenRequest startRequest];
}
{% endhighlight %}

Native signup
=============
The native signup flow is implemented using the `SPiDUser`. To create a SPiD Account a client token is needed, therefor the first step of `createAccountWithEmail` is to acquire a client token and then try to create the SPiD account. 
{% highlight objectivec %}
- (void)signupWithEmail:(NSString *)email andPassword:(NSString *)password {
    [SPiDUser createAccountWithEmail:email password:password completionHandler:^(NSError *error) {
        if (error) {
            // Something went wrong
        } else {
            // Successfully created SPiD account
            // Check your email for verification
        }
    }];
}
{% endhighlight %}

See the SPiDNativeExample for a simple application with native login and signup.

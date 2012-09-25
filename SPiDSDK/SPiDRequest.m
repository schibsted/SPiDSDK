//
//  SPiDRequest.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/17/12.
//  Copyright (c) 2012 Schibsted Payment. All rights reserved.
//

#import "SPiDRequest.h"

@implementation SPiDRequest

- (id)initWithURL:(NSString *)urlInput andHTTPMethod:(NSString *)method andCompletionHandler:(id)handler {

    if ([method isEqualToString:@""] || [method isEqualToString:@"GET"]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@?oauth_token=%@", urlInput, @"asdf"];
        NSURL *url = [NSURL URLWithString:urlStr];
        [self doAuthenticatedSPiDGetRequestWithURL:url];
    }
    return self;
}

// TODO: Should be init methods
- (void)doAuthenticatedMeRequestWithCompletionHandler:handler {
    NSString *urlStr = [NSString stringWithFormat:@"https://stage.payment.schibsted.no/api/2/me?oauth_token=%@", @"asdf"];
    url = [NSURL URLWithString:urlStr];
    httpMethod = @"GET";
    completionHandler = handler;
    [self doAuthenticatedSPiDGetRequestWithURL:url];
}

- (void)doAuthenticatedLoginsRequestWithCompletionHandler:handler andUserID:userID {
    //https://stage.payment.schibsted.no/api/2/user/101912/logins?oauth_token=
    NSString *urlStr = [NSString stringWithFormat:@"https://stage.payment.schibsted.no/api/2/user/%@/logins?oauth_token=%@", userID, @"asdf"];
    NSURL *url = [NSURL URLWithString:urlStr];
    url = [NSURL URLWithString:urlStr];
    httpMethod = @"GET";
    completionHandler = handler;
    [self doAuthenticatedSPiDGetRequestWithURL:url];
}

- (void)doAuthenticatedLogoutRequestWithCompletionHandler:handler {
    NSLog(@"Trying to logout");
    NSURL *redirectUri = [SPiDUtils urlEncodeString:@"sdktest://logout"];
    NSString *urlStr = [NSString stringWithFormat:@"https://stage.payment.schibsted.no/logout?redirect_uri=%@&oauth_token=%@", [redirectUri absoluteString], @"asdf"];
    url = [NSURL URLWithString:urlStr];
    /*
    if ([[SPiDClient sharedInstance] useWebView]) {
        [self setUrl:url];
        [self setHttpMethod:@"GET"];
        [self doAuthenticatedSPiDGetRequestWithURL:url];
    } else { */
    // Safari redirect
    completionHandler = handler;
    [[UIApplication sharedApplication] openURL:url];
    //}
}

// TODO: Should check token expiration and handle invalid tokens
- (void)doAuthenticatedSPiDGetRequestWithURL:(NSURL *)url {
    // if expired token, refresh?
    // if not logged in, throw error
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    [request setHTTPMethod:httpMethod];
    NSLog(@"URL: %@", [url absoluteString]);
    receivedData = [[NSMutableData alloc] init];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Request response");
    NSLog(@"URL: %@", [[response URL] absoluteString]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Data received");
    [receivedData appendData:data];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    //NSLog(@"redirecting to : %@", [request URL]);
    //NSString *redirectUrl = [[[SPiDClient sharedInstance] redirectURI] absoluteString];
    if ([[[request URL] absoluteString] hasPrefix:@"sdktest://logout"]) {
        // TODO: should check for token when making api calls
        //[[SPiDClient sharedInstance] setAccessToken:nil];
        return nil;
    } else {
        return request;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Finished");
    NSError *jsonError = nil;
    //NSLog(@"Request %@", [[NSString alloc] initWithData:[self receivedData] encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonObject = nil;
    if ([receivedData length] > 0) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:&jsonError];
    }

    if ([jsonObject objectForKey:@"error"]) {
        NSLog(@"SPiDSDK error: %@", [jsonObject objectForKey:@"error"]);
    }

    if (!jsonError) {
        completionHandler(jsonObject);
    } else {
        NSLog(@"SPiDSDK error: %@", [jsonError description]);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"SPiDSDK error: %@", [error description]);
}


@end
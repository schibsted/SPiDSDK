//
// Created by mikaellindstrom on 9/17/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SPiDRequest.h"


@implementation SPiDRequest

@synthesize url = _url;
@synthesize httpMethod = _httpMethod;
@synthesize completionHandler = _completionHandler;
@synthesize receivedData = _receivedData;

- (id)initWithURL:(NSString *)urlInput andHTTPMethod:(NSString *)method andCompletionHandler:(id)completionHandler {

    if ([method isEqualToString:@""] || [method isEqualToString:@"GET"]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@?oauth_token=%@", urlInput, [[SPiDClient sharedInstance] accessToken]];
        NSURL *url = [NSURL URLWithString:urlStr];
        [self doAuthenticatedSPiDGetRequestWithURL:url];
    }
    return self;
}

- (void)doAuthenticatedMeRequestWithCompletionHandler:completionHandler {
    NSString *urlStr = [NSString stringWithFormat:@"https://stage.payment.schibsted.no/api/2/me?oauth_token=%@", [[SPiDClient sharedInstance] accessToken]];
    NSURL *url = [NSURL URLWithString:urlStr];
    [self setUrl:url];
    [self setHttpMethod:@"GET"];
    [self setCompletionHandler:completionHandler];
    [self doAuthenticatedSPiDGetRequestWithURL:url];
}

- (void)doAuthenticatedLoginsRequestWithCompletionHandler:completionHandler andUserID:userID {
    //https://stage.payment.schibsted.no/api/2/user/101912/logins?oauth_token=
    NSString *urlStr = [NSString stringWithFormat:@"https://stage.payment.schibsted.no/api/2/user/%@/logins?oauth_token=%@", userID, [[SPiDClient sharedInstance] accessToken]];
    NSURL *url = [NSURL URLWithString:urlStr];
    [self setUrl:url];
    [self setHttpMethod:@"GET"];
    [self setCompletionHandler:completionHandler];
    [self doAuthenticatedSPiDGetRequestWithURL:url];
}

- (void)doAuthenticatedLogoutRequestWithCompletionHandler:completionHandler {
    NSLog(@"Trying to logout");
    NSURL *redirectUrl = [SPiDURL urlEncodeString:@"sdktest://logout"];
    NSString *urlStr = [NSString stringWithFormat:@"https://stage.payment.schibsted.no/logout?redirect_uri=%@&oauth_token=%@", [redirectUrl absoluteString], [[SPiDClient sharedInstance] accessToken]];
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[SPiDClient sharedInstance] useWebView]) {
        [self setUrl:url];
        [self setHttpMethod:@"GET"];
        [self setCompletionHandler:completionHandler];
        [self doAuthenticatedSPiDGetRequestWithURL:url];
    } else { // Safari redirect
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)doAuthenticatedSPiDGetRequestWithURL:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    [request setHTTPMethod:[self httpMethod]];
    NSLog(@"URL: %@", [url absoluteString]);
    [self setReceivedData:[[NSMutableData alloc] init]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Request response");
    NSLog(@"URL: %@", [[response URL] absoluteString]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Data received");
    [[self receivedData] appendData:data];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    NSLog(@"redirecting to : %@", [request URL]);
    NSString *redirectUrl = [[[SPiDClient sharedInstance] redirectURL] absoluteString];
    if ([[[request URL] absoluteString] hasPrefix:@"sdktest://logout"]) {
        // TODO: should check for token when making api calls
        [[SPiDClient sharedInstance] setAccessToken:nil];
        return nil;
    } else {
        return request;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Done Request");
    NSError *jsonError = nil;
    NSLog(@"Request %@", [[NSString alloc] initWithData:[self receivedData] encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonObject = nil;
    if ([[self receivedData] length] > 0) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:[self receivedData] options:kNilOptions error:&jsonError];
    }

    if (!jsonError) {
        _completionHandler(jsonObject);
    } else {
        NSLog(@"Error: %@", [jsonError description]);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", [error description]);
}


@end
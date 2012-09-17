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
}

- (void)doAuthenticatedMeRequestWithCompletionHandler:completionHandler {
    NSString *urlStr = [NSString stringWithFormat:@"https://stage.payment.schibsted.no/api/2/me?oauth_token=%@", [[SPiDClient sharedInstance] accessToken]];
    NSURL *url = [NSURL URLWithString:urlStr];
    [self setUrl:url];
    [self setHttpMethod:@"GET"];
    [self setCompletionHandler:completionHandler];
    [self doAuthenticatedSPiDGetRequestWithURL:url];
}

- (void)doAuthenticatedSPiDGetRequestWithURL:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    [request setHTTPMethod:[self httpMethod]];
    [self setReceivedData:[[NSMutableData alloc] init]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"response");
    NSLog([[response URL] absoluteString]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Data received");
    //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [[self receivedData] appendData:data];
/*
    NSError *jsonError = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];

    if (!jsonError && [jsonObject objectForKey:@"access_token"]) {
        [self setAccessToken:[jsonObject objectForKey:@"access_token"]];
        NSLog(@"Got access_token: %@", [self accessToken]);
    }
    */
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Done request");
    NSError *jsonError = nil;
    NSLog(@"%@", [self receivedData]);
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[self receivedData] options:kNilOptions error:&jsonError];

    if (!jsonError) {
        _completionHandler(jsonObject);
    }
}


@end
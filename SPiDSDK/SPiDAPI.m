//
//  SPiDAPI.m
//  SPiDSDK
//
//  Created by Mikael Lindström on 9/12/12.
//  Copyright (c) 2012 Mikael Lindström. All rights reserved.
//

#import "SPiDAPI.h"

@implementation SPiDAPI

- (id)initWithGTMOauth2Authentication:(GTMOAuth2Authentication *)gtmOath2Authentication {
    authentication = gtmOath2Authentication;
    return self;
}

- (UIViewController *)authorize {
    NSLog(@"Trying to authorize");
    if (authentication) {
        SEL finishedSel = @selector(viewController:finishedWithAuth:error:);
        // if signedin signout
        GTMOAuth2ViewControllerTouch *viewController = [GTMOAuth2ViewControllerTouch controllerWithAuthentication:authentication authorizationURL:[NSURL URLWithString:@"https://stage.payment.schibsted.no/auth/start"] keychainItemName:nil delegate:self finishedSelector:finishedSel];

        NSString *html = @"<html><body bgcolor=silver><div align=center>Loading sign-in page...</div></body></html>";
        viewController.initialHTMLString = html;

        NSLog(@"Created viewcontroller");
        return viewController;
    }
    return nil;
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        NSLog(@"Authentication error: %@", error);

        authentication = nil;
    } else {
        authentication = auth;
        NSLog(@"Successful! Code: %@, AccessToken: %@", authentication.code, authentication.accessToken);
//        [self doAnAuthenticatedAPIFetch];
    }
}

NSMutableData *responseData;


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *data = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSLog(@"%@", data);
}

- (void)doAnAuthenticatedAPIFetch {
    NSString *urlStr = [NSString stringWithFormat:@"https://stage.payment.schibsted.no/api/2/me?oauth_token=%@", authentication.accessToken];

    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    NSLog(@"canAuth: %d", [authentication canAuthorize]);
    responseData = [NSMutableData data];
    [request setHTTPMethod:@"GET"];
    [authentication authorizeRequest:nil completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error");
        } else {
            NSLog([request debugDescription]);
            NSLog([[request allHTTPHeaderFields] debugDescription]);
            [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }];
}


@end

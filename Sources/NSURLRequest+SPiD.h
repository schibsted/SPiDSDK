//
//  NSURLRequest+SPiD.h
//  SPiDSDK
//
//  Created by Joakim Gyllström on 2015-12-18.
//  Copyright © 2015 Mikael Lindström. All rights reserved.
//

@import Foundation;

@interface NSURLRequest (SPiD)

+ (NSURLRequest *)sp_requestWithURL:(NSURL *)URL method:(NSString *)method andBody:(NSString *)body;

@end

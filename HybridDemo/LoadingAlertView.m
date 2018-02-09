//
//  LoadingAlertView
//  SPiDHybridApp
//
//  Copyright (c) 2013 Schibsted Payment. All rights reserved.
//

#import "LoadingAlertView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingAlertView

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 120, 120)];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.layer.cornerRadius = 15;
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];

    // Add loadingSpinner label
    UILabel *loadLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 81, 22)];
    loadLabel.text = @"Loading";
    loadLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    loadLabel.textAlignment = NSTextAlignmentCenter;
    loadLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    loadLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:loadLabel];

    // Add spinner
    UIActivityIndicatorView *spinning = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinning.frame = CGRectMake(42, 54, 37, 37);
    [spinning startAnimating];
    [self addSubview:spinning];
}

/*
-(void)showAlert{
    CGFloat horizontalCenter = self.window.frame.size.width / 2;
    CGFloat verticalCenter = self.window.frame.size.height / 2;

    CGPoint offsent = [self convertPoint:CGPointZero toView:nil];
    self.center = CGPointMake(horizontalCenter, verticalCenter- offsent.y/2);
}
*/

- (void)dismissAlert {
    [self removeFromSuperview];
}

@end
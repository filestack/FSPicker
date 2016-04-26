//
//  UINavigationController+Progress.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 11/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "UINavigationController+Progress.h"

@implementation UINavigationController (Progress)

- (FSProgressView *)fsProgressView {
    for (id subview in self.view.subviews) {
        if ([subview isMemberOfClass:[FSProgressView class]]) {
            return (FSProgressView *)subview;
        }
    }

    CGFloat frameY = self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
    CGFloat frameWidth = self.navigationBar.frame.size.width;
    CGRect frame = CGRectMake(0, frameY, frameWidth, 2);
    FSProgressView *progressView = [[FSProgressView alloc] initWithNavigationController:self frame:frame];
    [self.view addSubview:progressView];
    [progressView setupConstraints];
    return progressView;
}

- (void)fsResetProgressView {
    self.fsProgressView.hidden = YES;
    self.fsProgressView.progress = 0;
    self.fsProgressView.alpha = 1;
}

@end

//
//  FSProgressView.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 11/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSProgressView.h"

@interface FSProgressView ()

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation FSProgressView

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController frame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _navigationController = navigationController;
        self.tintColor = [UIColor colorWithRed:0.96 green:0.29 blue:0.05 alpha:1];
        self.trackTintColor = [UIColor colorWithRed:1 green:0.64 blue:0.51 alpha:1];
        self.hidden = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }

    return self;
}

- (void)setupConstraints {
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:2];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.navigationController.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1
                                                              constant:0];
    NSLayoutConstraint *position = [NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.navigationController.navigationBar
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1
                                                                 constant:0];

    [self addConstraint:height];
    [self.navigationController.view addConstraints:@[width, position]];
}

- (void)animateFadeOutAndHide {
    [UIView animateWithDuration:0.6 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.progress = 0;
    }];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    if ((int)self.alpha != 1) {
        self.alpha = 1.0;
    }

    if (self.hidden) {
        self.hidden = NO;
    }

    [super setProgress:progress animated:animated];
}

@end
//
// FSTableViewCell.m
// FSPicker
//
// Created by Łukasz Cichecki on 24/02/16.
// Copyright (c) 2016 Filestack. All rights reserved.
//

#import "FSTableViewCell.h"

@implementation FSTableViewCell

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = selectedBackgroundColor;
    self.selectedBackgroundView = bgView;
}

- (void)setImageViewBorderColor:(UIColor *)imageViewBorderColor {
    self.imageView.layer.borderColor = imageViewBorderColor.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.imageView.frame = CGRectMake(16, 10, 70, 70);
    self.textLabel.frame = CGRectMake(102, 25, self.frame.size.width - 140, 20);
    self.detailTextLabel.frame = CGRectMake(102, 45, 50, 20);
}

@end

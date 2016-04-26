//
// UILabel+Appearance.m
// FSPicker
//
// Created by Łukasz Cichecki on 24/02/16.
// Copyright (c) 2016 Filestack. All rights reserved.
//

#import "UILabel+Appearance.h"
#import "FSTableViewCellTag.h"

@implementation UILabel (Appearance)

- (void)setAppearanceTextColor:(UIColor *)color {
    if (self.tag != FSTableViewCellTagDetail) {
        self.textColor = color;
    }
}

- (void)setAppearanceHighlightedTextColor:(UIColor *)color {
    self.highlightedTextColor = color;
}

@end

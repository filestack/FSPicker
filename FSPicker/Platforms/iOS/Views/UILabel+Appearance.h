//
// UILabel+Appearance.h
// FSPicker
//
// Created by Łukasz Cichecki on 24/02/16.
// Copyright (c) 2016 Filestack. All rights reserved.
//

@import UIKit;

@interface UILabel (Appearance)

- (void)setAppearanceTextColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setAppearanceHighlightedTextColor:(UIColor *)color UI_APPEARANCE_SELECTOR;

@end

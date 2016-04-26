//
// FSTableViewCell.h
// FSPicker
//
// Created by Łukasz Cichecki on 24/02/16.
// Copyright (c) 2016 Filestack. All rights reserved.
//

@import UIKit;

@interface FSTableViewCell : UITableViewCell

@property (nonatomic, copy) UIColor *selectedBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *imageViewBorderColor UI_APPEARANCE_SELECTOR;

@end

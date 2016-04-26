//
// FSAlbumsViewController.h
// FSPicker
//
// Created by Łukasz Cichecki on 24/02/16.
// Copyright (c) 2016 Filestack. All rights reserved.
//

@import UIKit;
@class FSConfig;
@class FSSource;

@interface FSAlbumsViewController : UITableViewController

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source;

@end

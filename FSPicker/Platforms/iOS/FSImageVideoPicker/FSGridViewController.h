//
// FSGridViewController.h
// FSPicker
//
// Created by Łukasz Cichecki on 24/02/16.
// Copyright (c) 2016 Filestack. All rights reserved.
//

@import UIKit;
@import Photos;

@class FSConfig;
@class FSSource;

@interface FSGridViewController : UICollectionViewController

@property (nonatomic, strong) PHFetchResult *assetsFetchResult;

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source;

@end

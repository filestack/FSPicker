//
//  FSSearchViewController.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 01/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;
@class FSSource;
@class FSConfig;

@interface FSSearchViewController : UICollectionViewController

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source;

@end

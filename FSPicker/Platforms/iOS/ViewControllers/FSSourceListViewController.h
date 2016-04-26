//
//  FSSourceListViewController.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 02/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;
@class FSConfig;

@interface FSSourceListViewController : UITableViewController

- (instancetype)initWithConfig:(FSConfig *)config;

@end

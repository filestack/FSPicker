//
//  FSSourceTableViewController.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 10/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;
@class FSContentItem;
@class FSSourceViewController;

@interface FSSourceTableViewController : UITableViewController

@property (nonatomic, weak) FSSourceViewController *sourceController;
@property (nonatomic, assign) BOOL alreadyDisplayed;

- (void)refreshControlEnabled:(BOOL)enabled;
- (void)contentDataReceived:(NSArray<FSContentItem *> *)contentData isNextPageData:(BOOL)isNextPageData;
- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateTableInsetsForToolbarHidden:(BOOL)hidden currentlyHidden:(BOOL)currentlyHidden toolbarHeight:(CGFloat)height;

@end

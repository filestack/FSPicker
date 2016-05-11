//
//  FSSourceCollectionViewController.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 10/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;
@class FSContentItem;
@class FSSourceViewController;

@interface FSSourceCollectionViewController : UICollectionViewController

@property (nonatomic, weak) FSSourceViewController *sourceController;
@property (nonatomic, assign) BOOL alreadyDisplayed;
@property (nonatomic, assign) BOOL selectMultiple;

- (void)clearAllCollectionItems;
- (void)refreshControlEnabled:(BOOL)enabled;
- (void)contentDataReceived:(NSArray<FSContentItem *> *)contentData isNextPageData:(BOOL)isNextPageData;
- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateCollectionInsetsForToolbarHidden:(BOOL)hidden currentlyHidden:(BOOL)currentlyHidden toolbarHeight:(CGFloat)height;

@end

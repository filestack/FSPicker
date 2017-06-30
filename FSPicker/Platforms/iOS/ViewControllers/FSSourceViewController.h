//
//  FSSourceViewController.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 08/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;
@class FSConfig;
@class FSSource;
@class FSContentItem;

@interface FSSourceViewController : UIViewController

@property (nonatomic, assign) BOOL inPickMode;
@property (nonatomic, copy) NSString *loadPath;
@property (nonatomic, strong, readonly) NSString *nextPage;
@property (nonatomic, assign, readonly) BOOL lastPage;
@property (nonatomic, assign, readonly) BOOL inListView;
@property (nonatomic, strong, readonly) FSSource *source;

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source;
- (void)triggerDataRefresh:(void (^)(BOOL success))completion;
- (void)loadNextPage;
- (void)selectContentItem:(FSContentItem *)item atIndexPath:(NSIndexPath *)indexPath forTableView:(BOOL)tableView collectionView:(BOOL)collectionView;
- (void)deselectContentItem:(FSContentItem *)item atIndexPath:(NSIndexPath *)indexPath forTableView:(BOOL)tableView collectionView:(BOOL)collectionView;
- (void)clearSelectedContent;
- (void)loadDirectory:(NSString *)directoryPath;
- (BOOL)isContentItemSelected:(FSContentItem *)item;

@end

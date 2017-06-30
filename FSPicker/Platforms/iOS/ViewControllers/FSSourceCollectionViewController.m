//
//  FSSourceCollectionViewController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 10/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSourceCollectionViewController.h"
#import "UICollectionViewFlowLayout+FSPicker.h"
#import "FSSaveSourceViewController.h"
#import "FSSourceViewController.h"
#import "FSCollectionViewCell.h"
#import "FSContentItem.h"
#import "FSImage.h"
#import "FSSource.h"
#import "NSURLResponse+ImageMimeType.h"
#import "UIImage+Scale.h"

@interface FSSourceCollectionViewController ()

@property (nonatomic, strong) NSArray<FSContentItem *> *contentData;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectedIndexPaths;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIImage *selectedOverlay;
@property (nonatomic, assign) BOOL isLoadingNextPage;

@end

@implementation FSSourceCollectionViewController

static NSString * const reuseIdentifier = @"fsCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupRefreshControl];
    [self setupCollectionView];

    self.selectedIndexPaths = [[NSMutableArray alloc] init];
    self.selectedOverlay = [FSImage cellSelectedOverlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Fix refresh control "jump" on first refresh,
    // or invalid insets if no view interaction was done and you have switched between views:
    // list -> grid -> list -> grid resulted in invalid insets... I know, right?
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
        [self.refreshControl endRefreshing];
    });
    [self updateCollectionViewContentInsets];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshControl endRefreshing];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    [layout calculateAndSetItemSizeReversed:NO];
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[FSCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    // Since sendSubviewToBack won't cooperate.
    self.refreshControl.layer.zPosition = -1;
    // Fix invalid refresh control title position on first refresh.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - Helper methods

- (void)setContentData:(NSArray<FSContentItem *> *)contentData isNextPage:(BOOL)isNextPage newIndexPaths:(NSArray<NSIndexPath *> *)newIndexPaths {

    if (isNextPage) {
        if (self.sourceController.lastPage) {
            NSInteger lastCellIndex = [self.collectionView numberOfItemsInSection:0] - 1;
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:lastCellIndex inSection:0]]];
        }
        self.contentData = contentData;
        [self.collectionView insertItemsAtIndexPaths:newIndexPaths];
    } else {
        self.contentData = contentData;
        // Smooth the endRefreshing and reloading grid data animation.
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }];

        [self.refreshControl endRefreshing];
        [CATransaction commit];
    }
}

- (void)refreshControlEnabled:(BOOL)enabled {
    if (!enabled) {
        [self.refreshControl removeFromSuperview];
        self.refreshControl = nil;
    } else if (!self.refreshControl) {
        [self setupRefreshControl];
    }
}

- (void)contentDataReceived:(NSArray<FSContentItem *> *)contentData isNextPageData:(BOOL)isNextPageData {
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSMutableArray *newIndexPaths;

    if (isNextPageData) {
        NSInteger currentRowCount = self.contentData.count;
        NSInteger noOfIndexPathsToAdd = contentData.count;
        newIndexPaths = [[NSMutableArray alloc] init];

        for (int i = 0; i < noOfIndexPathsToAdd; i++) {
            [newIndexPaths addObject:[NSIndexPath indexPathForRow:currentRowCount + i inSection:0]];
        }

        [data addObjectsFromArray:self.contentData];
    }

    [data addObjectsFromArray:contentData];
    [self setContentData:data isNextPage:isNextPageData newIndexPaths:newIndexPaths];
    self.isLoadingNextPage = NO;
}

- (FSContentItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > (long)self.contentData.count - 1) {
        return nil;
    }

    return self.contentData[indexPath.row];
}

- (void)refreshData {
    self.collectionView.userInteractionEnabled = NO;
    [self.sourceController triggerDataRefresh:^(BOOL success) {
        self.collectionView.userInteractionEnabled = YES;
        self.isLoadingNextPage = NO;
        // refreshControl's endRefreshing is called in setContentData in case of success.
        if (!success) {
            [self.refreshControl endRefreshing];
        }
    }];
}

#pragma mark - Collection view update insets

// This fine method is required to fix tableView content insets if this controller is contained in another controller
// that is contained in navigation controller and there is yet another view controller contained in this controller's parent.
// Heh...

- (void)updateCollectionViewContentInsets {
    UIEdgeInsets currentInsets = self.collectionView.contentInset;
    CGPoint currentOffset = self.collectionView.contentOffset;
    CGFloat topInset = [self topInset];

    BOOL refreshingData = [self.refreshControl isRefreshing];
    if (currentInsets.top > 64 || refreshingData) {
        if (refreshingData) {
            topInset += self.refreshControl.frame.size.height;
        } else {
            topInset = currentInsets.top;
        }
    }

    self.collectionView.contentInset = UIEdgeInsetsMake(topInset, currentInsets.left, currentInsets.bottom, currentInsets.right);

    if (!self.alreadyDisplayed) {
        self.collectionView.contentOffset = CGPointMake(currentOffset.x, currentOffset.y - topInset);
    }

    self.alreadyDisplayed = YES;
}

- (CGFloat)topInset {
    CGFloat topInset;

    if (self.navigationController.navigationBar.isTranslucent) {
        CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat navBarOriginY = self.navigationController.navigationBar.frame.origin.y;
        topInset = navBarHeight + navBarOriginY;
    } else {
        topInset = 0.0;
    }

    if ([self.refreshControl isRefreshing]) {
        topInset += self.refreshControl.frame.size.height;
    }

    return topInset;
}

#pragma mark Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.sourceController.nextPage && !self.sourceController.lastPage) {
        return self.contentData.count + 1;
    }

    return self.contentData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    FSContentItem *item = [self itemAtIndexPath:indexPath];

    if (indexPath.row == (long)self.contentData.count && self.sourceController.nextPage) {
        [self configureLoadingCell:cell];
    } else {
        [self configureCell:cell forItem:item atIndexPath:indexPath];
    }

    return cell;
}

- (void)configureLoadingCell:(FSCollectionViewCell *)cell {
    cell.backgroundColor = [UIColor clearColor];
    cell.type = FSCollectionViewCellTypeLoad;
    cell.imageView.layer.borderWidth = 0;
    cell.overlayImageView.image = nil;
    cell.userInteractionEnabled = NO;
    cell.titleLabel.hidden = YES;
    cell.imageView.image = nil;
}

- (void)configureCell:(FSCollectionViewCell *)cell forItem:(FSContentItem *)item atIndexPath:(NSIndexPath *)indexPath {
    [cell.activityIndicator stopAnimating];
    cell.taskHash = 0;

    if (!item) {
        [self configureLoadingCell:cell];
        return;
    }

    cell.userInteractionEnabled = YES;
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.contentMode = UIViewContentModeCenter;
    cell.imageView.layer.borderWidth = 1;
    cell.imageView.clipsToBounds = YES;

    if ([self.sourceController isContentItemSelected:item]) {
        [self markCellAsSelected:cell atIndexPath:indexPath];
    } else {
        cell.overlayImageView.image = nil;
    }

    if (item.isDirectory || !item.thumbExists) {
        cell.titleLabel.text = item.fileName;
        cell.titleLabel.hidden = NO;
    } else {
        cell.titleLabel.hidden = YES;
    }

    BOOL itemShouldPresentLabels = self.sourceController.source.itemsShouldPresentLabels;

    if (item.isDirectory) {
        cell.imageView.image = [FSImage iconNamed:@"icon-folder"];
        cell.type = FSCollectionViewCellTypeDirectory;
    } else {
        if (!item.thumbExists) {
            cell.imageView.image = [FSImage iconNamed:@"icon-file"];
            cell.type = FSCollectionViewCellTypeFile;
        } else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:item.thumbnailURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:120];

            cell.imageTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                UIImage *image;

                if (response.hasImageMIMEType && data && (cell.taskHash == cell.imageTask.hash)) {
                    image = [UIImage imageWithData:data];
                }

                if (!image) {
                    image = [FSImage iconNamed:@"icon-file"];
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (itemShouldPresentLabels) {
                        cell.type = FSCollectionViewCellTypeFile;
                        cell.titleLabel.text = item.fileName;
                        cell.titleLabel.hidden = NO;
                        cell.imageView.image = [image scaledToSize:CGSizeMake(32, 32)];
                    } else {
                        cell.type = FSCollectionViewCellTypeMedia;
                        cell.imageView.layer.borderWidth = 0;
                        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        cell.imageView.clipsToBounds = YES;
                        cell.imageView.image = image;
                    }
                });

                cell.imageTask = nil;
            }];

            cell.taskHash = cell.imageTask.hash;
            [cell.imageTask resume];
        }
    }
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.refreshControl isRefreshing]) {
        FSContentItem *item = [self itemAtIndexPath:indexPath];
        FSCollectionViewCell *cell = (FSCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

        if (item.isDirectory) {
            [self selectedDirectoryCell:cell atIndexPath:indexPath];
        } else if (![self.sourceController isMemberOfClass:[FSSaveSourceViewController class]]) {
            [self selectedCell:cell forItem:item atIndexPath:indexPath];
        } else {
            cell.selected = NO;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.refreshControl isRefreshing]) {
        FSCollectionViewCell *cell = (FSCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        FSContentItem *item = [self itemAtIndexPath:indexPath];

        [self deselectedCell:cell forItem:item atIndexPath:indexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.sourceController.nextPage && [self shouldLoadNextPage]) {
        self.isLoadingNextPage = YES;
        NSIndexPath *lastCellIndex = [NSIndexPath indexPathForRow:self.contentData.count inSection:0];
        FSCollectionViewCell *cell = (FSCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:lastCellIndex];
        [cell.activityIndicator startAnimating];
        [self.sourceController loadNextPage];
    }
}

- (BOOL)shouldLoadNextPage {
    if (self.isLoadingNextPage || [self.refreshControl isRefreshing]) {
        return NO;
    }

    CGFloat offsetY = self.collectionView.contentOffset.y;
    CGFloat contentHeight = self.collectionView.contentSize.height;
    CGFloat frameHeight = self.collectionView.frame.size.height;

    return offsetY > 0.0 && (offsetY > contentHeight - frameHeight);
}

#pragma mark - (De)Selection methods

- (void)markCellAsSelected:(FSCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.overlayImageView.image = self.selectedOverlay;
    cell.selected = YES;
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)selectedDirectoryCell:(FSCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FSContentItem *item = [self itemAtIndexPath:indexPath];

    // Clear all selection and collections
    [self clearAllCollectionItems];

    // Load directory
    [self.sourceController loadDirectory:item.linkPath];
}

- (void)selectedCell:(FSCollectionViewCell *)cell forItem:(FSContentItem *)item atIndexPath:(NSIndexPath *)indexPath {
    [self addItemToCollection:item indexPath:indexPath];
    if (self.selectMultiple) {
        cell.overlayImageView.image = self.selectedOverlay;
    }
}

- (void)deselectedCell:(FSCollectionViewCell *)cell forItem:(FSContentItem *)item atIndexPath:(NSIndexPath *)indexPath {
    [self clearCollectionItem:item indexPath:indexPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.overlayImageView.image = nil;
    });
}

- (void)clearCollectionItem:(FSContentItem *)item indexPath:(NSIndexPath *)indexPath {
    [self.sourceController deselectContentItem:item atIndexPath:indexPath forTableView:YES collectionView:NO];
    [self.selectedIndexPaths removeObject:indexPath];
}

- (void)addItemToCollection:(FSContentItem *)item indexPath:(NSIndexPath *)indexPath {
    [self.sourceController selectContentItem:item atIndexPath:indexPath forTableView:YES collectionView:NO];
    [self.selectedIndexPaths addObject:indexPath];
}

- (void)clearAllCollectionItems {
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        FSCollectionViewCell *cell = (FSCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        FSContentItem *item = [self itemAtIndexPath:indexPath];

        if (item.isDirectory) {
            [self clearCollectionItem:item indexPath:indexPath];
        } else {
            [self deselectedCell:cell forItem:item atIndexPath:indexPath];
        }
    }
}

- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - Collection layout

- (void)updateCollectionInsetsForToolbarHidden:(BOOL)hidden currentlyHidden:(BOOL)currentlyHidden toolbarHeight:(CGFloat)height {
    UIEdgeInsets currentInsets = self.collectionView.contentInset;
    CGPoint currentOffset = self.collectionView.contentOffset;
    CGFloat bottomInset;
    CGFloat yOffset;

    if (hidden) {
        bottomInset = 0.0;
        yOffset = -height;
    } else {
        bottomInset = height;
        yOffset = currentlyHidden ? height : 0.0;
    }

    self.collectionView.contentInset = UIEdgeInsetsMake(currentInsets.top, currentInsets.left, bottomInset, currentInsets.right);
    if (currentOffset.y > [self topInset]) {
        [self.collectionView setContentOffset:CGPointMake(currentOffset.x, currentOffset.y + yOffset) animated:YES];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateCollectionViewLayoutWithSize];

    // There is a bug when you rotate the view for the first time without ever triggering the refresh control.
    // When you do this, UITableViewWrapperView top inset is equal to status bar + nav bar + refresh control height.
    // If you end refreshing (even when refresh control is not refreshing) it will rotate to proper height.
    if (![self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self updateCollectionViewContentInsets];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        CGFloat toolbarHeight = self.navigationController.toolbar.frame.size.height;
        BOOL toolbarHidden = self.navigationController.toolbar.isHidden;
        [self updateCollectionInsetsForToolbarHidden:toolbarHidden currentlyHidden:toolbarHidden toolbarHeight:toolbarHeight];
    }];
}

- (void)updateCollectionViewLayoutWithSize {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;

    [layout calculateAndSetItemSizeReversed:YES];
    [layout invalidateLayout];
}

@end

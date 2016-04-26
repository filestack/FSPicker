//
//  FSSourceTableViewController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 10/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSourceTableViewController.h"
#import "FSSourceViewController.h"
#import "FSActivityIndicatorView.h"
#import "FSListTableViewCell.h"
#import "FSContentItem.h"
#import "FSImage.h"

@interface FSSourceTableViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSArray<FSContentItem *> *contentData;

@end

@implementation FSSourceTableViewController

static NSString *const reuseIdentifier = @"fsCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.refreshControl endRefreshing];
    [self updateTableViewContentInsets];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshControl endRefreshing];
}

#pragma mark - Setup view

- (void)setupTableView {
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Force fixed separator's left inset value.
    UIEdgeInsets separatorInsets = self.tableView.separatorInset;
    self.tableView.separatorInset = UIEdgeInsetsMake(separatorInsets.top, 62, separatorInsets.bottom, separatorInsets.right);
    [self updateTableViewContentInsets];
}

- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    // Fix invalid title position on first refresh.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - Helper methods

- (CGFloat)topInset {
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat navBarOriginY = self.navigationController.navigationBar.frame.origin.y;
    CGFloat topInset = navBarHeight + navBarOriginY;

    if ([self.refreshControl isRefreshing]) {
        topInset += self.refreshControl.frame.size.height;
    }

    return topInset;
}

- (void)refreshControlEnabled:(BOOL)enabled {
    if (!enabled) {
        self.refreshControl = nil;
    } else if (!self.refreshControl) {
        [self setupRefreshControl];
    }
}

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view update insets

// This fine method is required to fix tableView content insets if this controller is contained in another controller
// that is contained in navigation controller and there is yet another view controller contained in this controller's parent.
// Heh...

- (void)updateTableViewContentInsets {
    UIEdgeInsets currentInsets = self.tableView.contentInset;
    CGFloat topInset = [self topInset];
    if (currentInsets.top != 0 || !_alreadyDisplayed) {
        self.tableView.contentInset = UIEdgeInsetsMake(topInset, currentInsets.left, currentInsets.bottom, currentInsets.right);
        _alreadyDisplayed = YES;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // There is a bug when you rotate the view for the first time without ever triggering the refresh control.
    // When you do this, UITableViewWrapperView top inset is equal to status bar + nav bar + refresh control height.
    // If you end refreshing (even when refresh control is not refreshing) it will rotate to proper height.
    if (![self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self updateTableViewContentInsets];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        CGFloat toolbarHeight = self.navigationController.toolbar.frame.size.height;
        BOOL toolbarHidden = self.navigationController.toolbar.isHidden;
        [self updateTableInsetsForToolbarHidden:toolbarHidden currentlyHidden:toolbarHidden toolbarHeight:toolbarHeight];
    }];
}

- (void)updateTableInsetsForToolbarHidden:(BOOL)hidden currentlyHidden:(BOOL)currentlyHidden toolbarHeight:(CGFloat)height {
    UIEdgeInsets currentInsets = self.tableView.contentInset;
    CGPoint currentOffset = self.tableView.contentOffset;
    CGFloat bottomInset;
    CGFloat yOffset;

    if (hidden) {
        bottomInset = 0.0;
        yOffset = -height;
    } else {
        bottomInset = height;
        yOffset = currentlyHidden ? height : 0.0;
    }

    self.tableView.contentInset = UIEdgeInsetsMake(currentInsets.top, currentInsets.left, bottomInset, currentInsets.right);
    if (currentOffset.y > [self topInset]) {
        [self.tableView setContentOffset:CGPointMake(currentOffset.x, currentOffset.y + yOffset) animated:YES];
    }
}

#pragma mark - Table view data source

- (void)setContentData:(NSArray<FSContentItem *> *)contentData isNextPage:(BOOL)isNextPage newIndexPaths:(NSArray<NSIndexPath *> *)newIndexPaths {
    _contentData = contentData;

    if (_contentData.count != 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }

    if (isNextPage) {
        [self.tableView beginUpdates];

        if (_sourceController.lastPage) {
            // If this is the last page, remove the "LoadingCell" before inserting new rows.
            NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:0] - 1;
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:lastRowIndex inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }

        [self.tableView insertRowsAtIndexPaths:newIndexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    } else {
        // Smooth the endRefreshing and reloading table data animation.
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        }];

        [self.refreshControl endRefreshing];
        [CATransaction commit];
    }
}

- (void)refreshData {
    self.tableView.userInteractionEnabled = NO;
    [_sourceController triggerDataRefresh:^(BOOL success) {
        self.tableView.userInteractionEnabled = YES;
        // refreshControl's endRefreshing is called in setContentData in case of success.
        if (!success) {
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)contentDataReceived:(NSArray<FSContentItem *> *)contentData isNextPageData:(BOOL)isNextPageData {
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSMutableArray *newIndexPaths;

    if (isNextPageData) {
        NSInteger currentRowCount = _contentData.count;
        NSInteger noOfIndexPathsToAdd = contentData.count;
        newIndexPaths = [[NSMutableArray alloc] init];

        for (int i = 0; i < noOfIndexPathsToAdd; i++) {
            [newIndexPaths addObject:[NSIndexPath indexPathForRow:currentRowCount + i inSection:0]];
        }

        [data addObjectsFromArray:_contentData];
    }

    [data addObjectsFromArray:contentData];
    [self setContentData:data isNextPage:isNextPageData newIndexPaths:newIndexPaths];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_sourceController.nextPage && !_sourceController.lastPage) {
        return _contentData.count + 1;
    }

    return _contentData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (!cell) {
        cell = [[FSListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:reuseIdentifier];
    }

    if (indexPath.row == _contentData.count && _sourceController.nextPage) {
        [self configureLoadingCell:cell];
    } else {
        FSContentItem *item = [self itemAtIndexPath:indexPath];
        [self configureCell:cell forItem:item];

        if ([_sourceController isContentItemSelected:item]) {
            cell.selected = YES;
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.refreshControl isRefreshing] && indexPath.row == _contentData.count && _sourceController.nextPage) {
        [_sourceController loadNextPage];
    }
}

- (void)configureLoadingCell:(FSListTableViewCell *)cell {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.frame = CGRectMake((cell.frame.size.width / 2) - 10, (cell.frame.size.height / 2) - 10, 20, 20);
    cell.userInteractionEnabled = NO;
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;
    cell.textLabel.text = nil;
    cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0);
    [cell addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

- (void)configureCell:(FSListTableViewCell *)cell forItem:(FSContentItem *)item {
    if (!item) {
        [self configureLoadingCell:cell];
        return;
    }
    cell.userInteractionEnabled = YES;
    cell.separatorInset = self.tableView.separatorInset;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.alpha = 1.0;
    cell.textLabel.text = item.fileName;
    cell.detailTextLabel.text = item.detailDescription;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];

    if (item.isDirectory) {
        cell.imageView.image = [FSImage iconNamed:@"icon-folder"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (!item.thumbExists) {
        cell.imageView.image = [FSImage iconNamed:@"icon-file"];
    } else {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.alpha = 0.0;
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:item.thumbnailURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageView.image = [UIImage imageWithData:data];
                    [UIView animateWithDuration:0.1 animations:^{
                        cell.imageView.alpha = 1.0;
                    } completion:^(BOOL finished) {
                        [cell layoutSubviews];
                    }];
                });
            }
        }];

        [task resume];
    }
}

- (FSContentItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > _contentData.count - 1) {
        return nil;
    }

    return _contentData[indexPath.row];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.refreshControl isRefreshing]) {
        FSContentItem *item = [self itemAtIndexPath:indexPath];
        if (item.isDirectory) {
            [_sourceController clearSelectedContent];
            for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            [_sourceController loadDirectory:item.linkPath];
        } else {
            [_sourceController selectContentItem:item atIndexPath:indexPath forTableView:NO collectionView:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.refreshControl isRefreshing]) {
        [_sourceController deselectContentItem:[self itemAtIndexPath:indexPath] atIndexPath:indexPath forTableView:NO collectionView:YES];
    }
}

@end

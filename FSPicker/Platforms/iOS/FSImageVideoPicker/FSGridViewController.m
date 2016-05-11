//
// FSGridViewController.m
// FSPicker
//
// Created by Łukasz Cichecki on 24/02/16.
// Copyright (c) 2016 Filestack. All rights reserved.
//

#import "FSGridViewController.h"
#import "UICollectionViewFlowLayout+FSPicker.h"
#import "FSCollectionViewCell.h"
#import "FSImageFetcher.h"
#import "FSBarButtonItem.h"
#import "FSConfig.h"
#import "FSImage.h"
#import "FSUploader.h"
#import "FSUploadModalViewController.h"
#import "FSPickerController+Private.h"

@interface FSGridViewController ()

@property (nonatomic, strong) FSConfig *config;
@property (nonatomic, strong) FSSource *source;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) BOOL toolbarColorsSet;
@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedAssets;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectedIndexPaths;
@property (nonatomic, strong) UIImage *selectedOverlay;
@property (nonatomic, strong, readonly) UIBarButtonItem *uploadButton;

@end

@implementation FSGridViewController

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source {
    if ((self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]])) {
        _config = config;
        _source = source;
        _cachingImageManager = [[PHCachingImageManager alloc] init];
        self.collectionView.allowsMultipleSelection = YES;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    [self setupToolbar];
    self.selectedAssets = [[NSMutableArray alloc] init];
    self.selectedIndexPaths = [[NSMutableArray alloc] init];
    self.selectedOverlay = [FSImage cellSelectedOverlay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Collection view

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    [layout calculateAndSetItemSizeReversed:NO];
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    self.itemSize = layout.itemSize;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[FSCollectionViewCell class] forCellWithReuseIdentifier:@"fsCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsFetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fsCell" forIndexPath:indexPath];
    PHAsset *asset = self.assetsFetchResult[indexPath.row];

    if ([self.selectedIndexPaths containsObject:indexPath]) {
        [self markCellAsSelected:cell atIndexPath:indexPath];
    } else {
        cell.overlayImageView.image = nil;
    }

    cell.type = FSCollectionViewCellTypeMedia;

    [FSImageFetcher imageForAsset:asset
          withCachingImageManager:self.cachingImageManager
                        thumbSize:self.itemSize.width
                      contentMode:PHImageContentModeAspectFill
                      imageResult:^(UIImage *image) {
        cell.imageView.image = image;
    }];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FSCollectionViewCell *cell = (FSCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self markCellAsSelected:cell atIndexPath:indexPath];
    [self.selectedAssets addObject:self.assetsFetchResult[indexPath.row]];
    [self.selectedIndexPaths addObject:indexPath];

    if (self.config.selectMultiple) {
        [self updateToolbar];
    } else {
        [self uploadSelectedAssets];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    FSCollectionViewCell *cell = (FSCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.overlayImageView.image = nil;
    [self.selectedAssets removeObject:self.assetsFetchResult[indexPath.row]];
    [self.selectedIndexPaths removeObject:indexPath];
    [self updateToolbar];
}

- (void)markCellAsSelected:(FSCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.overlayImageView.image = self.selectedOverlay;
    cell.selected = YES;
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - Upload

- (void)uploadSelectedAssets {
    FSUploadModalViewController *uploadModal = [[FSUploadModalViewController alloc] init];
    uploadModal.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    FSUploader *uploader = [[FSUploader alloc] initWithConfig:self.config source:self.source];
    uploader.uploadModalDelegate = uploadModal;
    uploader.pickerDelegate = (FSPickerController *)self.navigationController;

    [self presentViewController:uploadModal animated:YES completion:nil];
    [uploader uploadLocalItems:self.selectedAssets];
    [self clearSelectedAssets];
}

- (void)clearSelectedAssets {
    [self.selectedAssets removeAllObjects];

    for (NSIndexPath *indexPath in self.selectedIndexPaths) {
        [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
    }

    [self.selectedIndexPaths removeAllObjects];
    [self updateToolbar];
}

#pragma mark - Toolbar

- (void)setupToolbar {
    [self setToolbarItems:@[[self spaceButtonItem], [self uploadButtonItem], [self spaceButtonItem]] animated:NO];
}

- (UIBarButtonItem *)spaceButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)uploadButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(uploadSelectedAssets)];
}

- (void)updateToolbar {
    if (!self.toolbarColorsSet) {
        self.toolbarColorsSet = YES;
        self.navigationController.toolbar.barTintColor = [FSBarButtonItem appearance].backgroundColor;
        self.navigationController.toolbar.tintColor = [FSBarButtonItem appearance].normalTextColor;
    }

    if (self.selectedAssets.count > 0) {
        [self.navigationController setToolbarHidden:NO animated:YES];
        [self updateToolbarButtonTitle];
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

- (void)updateToolbarButtonTitle {
    NSString *title;

    if ((long)self.selectedAssets.count > self.config.maxFiles && self.config.maxFiles != 0) {
        title = [NSString stringWithFormat:@"Maximum %lu file%@", (long)self.config.maxFiles, self.config.maxFiles > 1 ? @"s" : @""];
        self.uploadButton.enabled = NO;
    } else {
        title = [NSString stringWithFormat:@"Upload %lu file%@", (unsigned long)self.selectedAssets.count, self.selectedAssets.count > 1 ? @"s" : @""];
        self.uploadButton.enabled = YES;
    }

    [self.uploadButton setTitle:title];
}

- (UIBarButtonItem *)uploadButton {
    return self.toolbarItems[1];
}

#pragma mark - Collection layout

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateCollectionViewLayoutWithSize];
}

- (void)updateCollectionViewLayoutWithSize {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;

    [layout calculateAndSetItemSizeReversed:YES];
    self.itemSize = layout.itemSize;
    [layout invalidateLayout];
}

@end

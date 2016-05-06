//
// FSAlbumsViewController.m
// FSPicker
//
// Created by Łukasz Cichecki on 24/02/16.
// Copyright (c) 2016 Filestack. All rights reserved.
//

#import "FSAlbumsViewController.h"
#import "FSImageFetcher.h"
#import "FSGridViewController.h"
#import "FSTableViewCell.h"
#import "FSConfig.h"
#import "FSSource.h"
#import "FSConfig+Private.h"

@interface FSAlbumsViewController ()

@property (nonatomic, strong) FSConfig *config;
@property (nonatomic, strong) FSSource *source;
@property (nonatomic, strong) NSArray<PHAssetCollection *> *albums;
@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;
@property (nonatomic, assign) CGFloat thumbSize;

@end

@implementation FSAlbumsViewController

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source{
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        _config = config;
        _source = source;
        _thumbSize = 70.0;
    }

    return self;
}

- (PHCachingImageManager *)cachingImageManager {
    if (!_cachingImageManager) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            _cachingImageManager = [[PHCachingImageManager alloc] init];
        }
    }

    return _cachingImageManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchAlbumsDataWithReload:NO];
    self.title = @"Albums";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self fetchAlbumsDataWithReload:YES];
                });
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fsCell"];

    if (!cell) {
        cell = [[FSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"fsCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.layer.borderWidth = 1;
    }

    PHAssetCollection *collection = self.albums[indexPath.row];
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    NSUInteger collectionTotalCount = assetsFetchResult.count;

    if (collectionTotalCount > 0) {
        cell.textLabel.text = collection.localizedTitle;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)collectionTotalCount];
        PHAsset *asset = assetsFetchResult[0];
        [FSImageFetcher imageForAsset:asset
              withCachingImageManager:self.cachingImageManager
                            thumbSize:self.thumbSize
                          contentMode:PHImageContentModeAspectFill
                          imageResult:^(UIImage *image) {
            cell.imageView.image = image;
        }];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSGridViewController *gridViewController = [[FSGridViewController alloc] initWithConfig:self.config source:self.source];
    gridViewController.title = self.albums[indexPath.row].localizedTitle;
    gridViewController.assetsFetchResult = [self fetchAssetsFromCollection:self.albums[indexPath.row]];

    [self.navigationController pushViewController:gridViewController animated:YES];
}

- (void)fetchAlbumsDataWithReload:(BOOL)reload {
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];

    NSMutableArray *assetsCollection = [[NSMutableArray alloc] init];

    [self addCollectionFromAlbums:smartAlbums toAssetsCollection:assetsCollection withFetchOptions:[self assetsFetchOptions]];
    [self addCollectionFromAlbums:userAlbums toAssetsCollection:assetsCollection withFetchOptions:[self assetsFetchOptions]];

    self.albums = assetsCollection;

    if (reload) {
        [self.tableView reloadData];
    }
}

- (PHFetchResult *)fetchAssetsFromCollection:(PHAssetCollection *)collection {
    return [PHAsset fetchAssetsInAssetCollection:collection options:[self assetsFetchOptions]];
}

- (PHFetchOptions *)assetsFetchOptions {
    NSMutableArray *predicateComponents = [[NSMutableArray alloc] init];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];

    if ([self.config showImages]) {
        [predicateComponents addObject:@"(mediaType == %d)"];
        [arguments addObject:@(PHAssetMediaTypeImage)];
    }

    if ([self.config showVideos]) {
        [predicateComponents addObject:@"(mediaType == %d)"];
        [arguments addObject:@(PHAssetMediaTypeVideo)];
    }

    NSString *predicateFormat = [predicateComponents componentsJoinedByString:@" || "];
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];

    return fetchOptions;
}

- (void)addCollectionFromAlbums:(PHFetchResult *)albums toAssetsCollection:(NSMutableArray *)assetsCollection withFetchOptions:(PHFetchOptions *)fetchOptions {
    for (PHAssetCollection *collection in albums) {
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];

        if (assetsFetchResult.count > 0) {
            [assetsCollection addObject:collection];
        }
    }
}

@end

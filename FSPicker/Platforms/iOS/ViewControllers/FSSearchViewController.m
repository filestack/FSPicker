//
//  FSSearchViewController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 01/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSImage.h"
#import "FSConfig.h"
#import "FSSource.h"
#import "FSSession.h"
#import "FSContentItem.h"
#import "FSBarButtonItem.h"
#import "FSCollectionViewCell.h"
#import "FSSearchViewController.h"
#import "FSPickerController+Private.h"
#import "UIAlertController+FSPicker.h"
#import "FSUploadModalViewController.h"
#import <Filestack/Filestack+FSPicker.h>
#import "UICollectionViewFlowLayout+FSPicker.h"

@interface FSSearchViewController () <UISearchResultsUpdating, UISearchBarDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) FSSource *source;
@property (nonatomic, strong) FSConfig *config;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImage *selectedOverlay;
@property (nonatomic, strong) NSMutableArray<FSContentItem *> *selectedContent;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectedIndexPaths;
@property (nonatomic, strong) NSArray<FSContentItem *> *contentData;
@property (nonatomic, assign) BOOL toolbarColorsSet;

@end

@implementation FSSearchViewController

static NSString * const reuseIdentifier = @"fsCell";
static NSString * const headerReuseIdentifier = @"headerView";

-(instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source {
    if ((self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]])) {
        _config = config;
        _source = source;
        _selectedContent = [[NSMutableArray alloc] init];
        _selectedOverlay = [FSImage cellSelectedOverlay];
        _selectedIndexPaths = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSearchController];
    [self setupCollectionView];
    [self setupActivityIndicator];
    [self setupToolbar];
    self.title = self.source.name;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchController setActive:YES];
    // Hacky, hacky
    [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:0.1];
}

- (void)showKeyboard {
    [self.searchController.searchBar becomeFirstResponder];
}

#pragma mark - Setup views

- (void)setupSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Search for images";
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
    self.searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchController.searchBar.autocapitalizationType = NO;
    [self.searchController.searchBar sizeToFit];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    [layout calculateAndSetItemSizeReversed:NO];
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[FSCollectionViewCell class]
            forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:headerReuseIdentifier];
}

- (void)setupActivityIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
}

#pragma mark - UISearchBar delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchController.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.collectionView.userInteractionEnabled = NO;
    [self.searchController.searchBar resignFirstResponder];
    [self.selectedContent removeAllObjects];
    [self.selectedIndexPaths removeAllObjects];
    [self updateToolbar];
    [self loadSourceContentWithSearchString:self.searchController.searchBar.text];

    self.searchController.active = NO;
}

#pragma mark - Loading data

- (void)loadSourceContentWithSearchString:(NSString *)searchString {
    [self.activityIndicator startAnimating];

    NSString *encodedSearchString = [searchString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSString *contentPath = [NSString stringWithFormat:@"%@/%@", self.source.rootPath, encodedSearchString];
    FSSession *session = [[FSSession alloc] initWithConfig:self.config mimeTypes:self.source.mimeTypes];
    NSDictionary *parameters = [session toQueryParametersWithFormat:@"info"];

    [Filestack getContentForPath:contentPath parameters:parameters completionHandler:^(NSDictionary *responseJSON, NSError *error) {
        self.collectionView.userInteractionEnabled = YES;
        [self.activityIndicator stopAnimating];

        if (error) {
            [self showAlertWithError:error];
        } else {
            self.contentData = [FSContentItem itemsFromResponseJSON:responseJSON];
        }
    }];
}

- (void)setContentData:(NSArray<FSContentItem *> *)contentData {
    _contentData = contentData;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)showAlertWithError:(NSError *)error {
    UIAlertController *alert = [UIAlertController fsAlertWithError:error];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contentData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    FSContentItem *item = [self itemAtIndexPath:indexPath];

    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.alpha = 0.0;
    cell.type = FSCollectionViewCellTypeMedia;

    if ([self.selectedIndexPaths containsObject:indexPath]) {
        cell.overlayImageView.image = self.selectedOverlay;
    } else {
        cell.overlayImageView.image = nil;
    }

    NSURL *dataTaskURL = [NSURL URLWithString:item.thumbnailURL];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:dataTaskURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = [UIImage imageWithData:data];
                [UIView animateWithDuration:0.1 animations:^{
                    cell.imageView.alpha = 1.0;
                }];
            });
        }
    }];

    [task resume];

    return cell;
}

- (FSContentItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.contentData[indexPath.row];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView* reusableView;
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                  withReuseIdentifier:headerReuseIdentifier
                                                                                         forIndexPath:indexPath];

        [headerView addSubview:self.searchController.searchBar];
        reusableView = headerView;

        return reusableView;
    }

    return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width, self.searchController.searchBar.frame.size.height);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateCollectionViewLayoutWithSize];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        CGFloat testOffset = self.collectionView.contentSize.height - self.collectionView.frame.size.height;
        if (self.collectionView.contentOffset.y > testOffset && testOffset > 0) {
            [self.collectionView setContentOffset:CGPointMake(0, testOffset) animated:YES];
        }
    }];
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FSCollectionViewCell *cell = (FSCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    FSContentItem *item = [self itemAtIndexPath:indexPath];

    [self selectedCell:cell forItem:item atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    FSCollectionViewCell *cell = (FSCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    FSContentItem *item = [self itemAtIndexPath:indexPath];

    [self deselectedCell:cell forItem:item atIndexPath:indexPath];
}

#pragma mark - (De)Selection methods

- (void)selectedCell:(FSCollectionViewCell *)cell forItem:(FSContentItem *)item atIndexPath:(NSIndexPath *)indexPath {
    cell.overlayImageView.image = self.selectedOverlay;
    [self.selectedContent addObject:item];
    [self.selectedIndexPaths addObject:indexPath];

    if (self.config.selectMultiple) {
        [self updateToolbar];
    } else {
        [self uploadSelectedContents];
    }
}

- (void)deselectedCell:(FSCollectionViewCell *)cell forItem:(FSContentItem *)item atIndexPath:(NSIndexPath *)indexPath {
    cell.overlayImageView.image = nil;
    [self.selectedContent removeObject:item];
    [self.selectedIndexPaths removeObject:indexPath];
    [self updateToolbar];
}

#pragma mark - Upload button

- (void)setupToolbar {
    [self setToolbarItems:@[[self spaceButtonItem], [self uploadButtonItem], [self spaceButtonItem]] animated:NO];
}

- (UIBarButtonItem *)spaceButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)uploadButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(uploadSelectedContents)];
}

- (void)updateToolbar {
    if (!self.toolbarColorsSet) {
        self.toolbarColorsSet = YES;
        self.navigationController.toolbar.barTintColor = [FSBarButtonItem appearance].backgroundColor;
        self.navigationController.toolbar.tintColor = [FSBarButtonItem appearance].normalTextColor;
    }

    if (self.selectedContent.count > 0) {
        [self updateListAndGridInsetsForToolbarHidden:NO];
        [self.navigationController setToolbarHidden:NO animated:YES];
        [self updateToolbarButtonTitle];
    } else {
        [self updateListAndGridInsetsForToolbarHidden:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

- (void)updateListAndGridInsetsForToolbarHidden:(BOOL)hidden {
    CGFloat toolbarHeight = self.navigationController.toolbar.frame.size.height;
    BOOL currentlyHidden = self.navigationController.toolbar.isHidden;
    [self updateCollectionInsetsForToolbarHidden:hidden currentlyHidden:currentlyHidden toolbarHeight:toolbarHeight];
}

- (void)updateToolbarButtonTitle {
    NSString *title;

    if ((long)self.selectedContent.count > self.config.maxFiles && self.config.maxFiles != 0) {
        title = [NSString stringWithFormat:@"Maximum %lu file%@", (long)self.config.maxFiles, self.config.maxFiles > 1 ? @"s" : @""];
        self.uploadButton.enabled = NO;
    } else {
        title = [NSString stringWithFormat:@"Upload %lu file%@", (unsigned long)self.selectedContent.count, self.selectedContent.count > 1 ? @"s" : @""];
        self.uploadButton.enabled = YES;
    }

    [self.uploadButton setTitle:title];
}

- (UIBarButtonItem *)uploadButton {
    return self.toolbarItems[1];
}

#pragma mark - Upload

- (void)uploadSelectedContents {
    FSUploadModalViewController *uploadModal = [[FSUploadModalViewController alloc] init];
    uploadModal.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    FSUploader *uploader = [[FSUploader alloc] initWithConfig:self.config source:self.source];
    uploader.uploadModalDelegate = uploadModal;
    uploader.pickerDelegate = (FSPickerController *)self.navigationController;

    [self presentViewController:uploadModal animated:YES completion:nil];
    [uploader uploadCloudItems:self.selectedContent];

    [self.selectedContent removeAllObjects];

    for (NSIndexPath *indexPath in [self.selectedIndexPaths copy]) {
        [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
    }

    [self.selectedIndexPaths removeAllObjects];
    [self updateToolbar];
}

- (CGFloat)topInset {
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat navBarOriginY = self.navigationController.navigationBar.frame.origin.y;
    CGFloat searchBarHeight = self.searchController.searchBar.frame.size.height;
    return navBarHeight + navBarOriginY + searchBarHeight;
}

- (void)updateCollectionInsetsForToolbarHidden:(BOOL)hidden currentlyHidden:(BOOL)currentlyHidden toolbarHeight:(CGFloat)height {
    CGPoint currentOffset = self.collectionView.contentOffset;
    CGFloat yOffset;

    if (hidden) {
        yOffset = -height;
    } else {
        yOffset = currentlyHidden ? height : 0.0;
    }

    if (currentOffset.y > [self topInset]) {
        [self.collectionView setContentOffset:CGPointMake(currentOffset.x, currentOffset.y + yOffset) animated:YES];
    }
}

- (void)updateCollectionViewLayoutWithSize {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;

    [layout calculateAndSetItemSizeReversed:YES];
    [layout invalidateLayout];
}

- (void)dealloc {
    [self.searchController.view removeFromSuperview];
}

@end

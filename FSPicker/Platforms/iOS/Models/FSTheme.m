//
// FSTheme.m
// FSPicker
//
// Created by Łukasz Cichecki on 24/02/16.
// Copyright (c) 2016 Filestack. All rights reserved.
//

#import "FSTheme.h"
#import "FSBarButtonItem.h"
#import "FSTableViewCell.h"
#import "FSSourceTableViewCell.h"
#import "UILabel+Appearance.h"
#import "UIRefreshControl+Appearance.h"
#import "FSCollectionViewCell.h"
#import "FSListTableViewCell.h"
#import "KAProgressLabel.h"

@implementation FSTheme

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)applyToController:(UIResponder *)controller {
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)controller;

        navigationController.navigationBar.barStyle = self.navigationBarStyle;

        if (self.navigationBarBackgroundColor) {
            navigationController.navigationBar.barTintColor = self.navigationBarBackgroundColor;
            navigationController.popoverPresentationController.backgroundColor = self.navigationBarBackgroundColor;
        }

        if (self.navigationBarTintColor) {
            navigationController.navigationBar.tintColor = self.navigationBarTintColor;
        }

        if (self.navigationBarTitleColor) {
            [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : self.navigationBarTitleColor}];
        }
    }

    if (self.headerFooterViewTintColor) {
        [UITableViewHeaderFooterView appearanceWhenContainedIn:[controller class], nil].tintColor = self.headerFooterViewTintColor;
    }

    if (self.headerFooterViewTextColor) {
        [UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], [controller class], nil].textColor = self.headerFooterViewTextColor;
    }

    if (self.tableViewBackgroundColor) {
        [UITableView appearanceWhenContainedIn:[controller class], nil].backgroundColor = self.tableViewBackgroundColor;
    }

    if (self.tableViewSeparatorColor) {
        [UITableView appearanceWhenContainedIn:[controller class], nil].separatorColor = self.tableViewSeparatorColor;
    }

    if (self.tableViewCellBackgroundColor) {
        [FSTableViewCell appearance].backgroundColor = self.tableViewCellBackgroundColor;
        [FSSourceTableViewCell appearance].backgroundColor = self.tableViewCellBackgroundColor;
        [FSListTableViewCell appearance].backgroundColor = self.tableViewCellBackgroundColor;
    }

    if (self.tableViewCellSelectedBackgroundColor) {
        [FSTableViewCell appearance].selectedBackgroundColor = self.tableViewCellSelectedBackgroundColor;
        [FSSourceTableViewCell appearance].selectedBackgroundColor = self.tableViewCellSelectedBackgroundColor;
        [FSListTableViewCell appearance].selectedBackgroundColor = self.tableViewCellSelectedBackgroundColor;
    }

    if (self.cellIconTintColor) {
        [FSTableViewCell appearance].tintColor = self.cellIconTintColor;
        [FSSourceTableViewCell appearance].tintColor = self.cellIconTintColor;
        [FSListTableViewCell appearance].tintColor = self.cellIconTintColor;
    }

    if (self.tableViewCellTextColor) {
        [UILabel appearanceWhenContainedIn:[UITableView class], [controller class], nil].appearanceTextColor = self.tableViewCellTextColor;
    }

    if (self.tableViewCellSelectedTextColor) {
        [UILabel appearanceWhenContainedIn:[UITableView class], [controller class], nil].appearanceHighlightedTextColor = self.tableViewCellSelectedTextColor;
    }

    if (self.tableViewCellImageViewBorderColor) {
        [FSTableViewCell appearance].imageViewBorderColor = self.tableViewCellImageViewBorderColor;
    }

    if (self.collectionViewBackgroundColor) {
        [UICollectionView appearanceWhenContainedIn:[controller class], nil].backgroundColor = self.collectionViewBackgroundColor;
    }

    if (self.collectionViewCellBackgroundColor) {
        [FSCollectionViewCell appearance].backgroundColor = self.collectionViewCellBackgroundColor;
    }

    if (self.collectionViewCellBorderColor) {
        [FSCollectionViewCell appearance].appearanceBorderColor = self.collectionViewCellBorderColor;
    }

    if (self.collectionViewCellTitleTextColor) {
        [FSCollectionViewCell appearance].appearanceTitleLabelTextColor = self.collectionViewCellTitleTextColor;
    }

    if (self.uploadButtonBackgroundColor) {
        [FSBarButtonItem appearance].backgroundColor = self.uploadButtonBackgroundColor;
    }

    if (self.uploadButtonTextColor) {
        [FSBarButtonItem appearance].normalTextColor = self.uploadButtonTextColor;
    }

    if (self.cellIconTintColor) {
        [UIImageView appearanceWhenContainedIn:[controller class], nil].tintColor = self.cellIconTintColor;
    }

    if (self.refreshControlTintColor) {
        [UIRefreshControl appearanceWhenContainedIn:[controller class], nil].tintColor = self.refreshControlTintColor;
    }

    if (self.refreshControlBackgroundColor) {
        [UIRefreshControl appearanceWhenContainedIn:[controller class], nil].backgroundColor = self.refreshControlBackgroundColor;
    }

    if (self.refreshControlAttributedTitle) {
        [UIRefreshControl appearanceWhenContainedIn:[controller class], nil].customAttributedTitle = self.refreshControlAttributedTitle;
    }

    if (self.searchBarBackgroundColor) {
        [UISearchBar appearanceWhenContainedIn:[controller class], nil].barTintColor = self.searchBarBackgroundColor;
    }

    if (self.searchBarTintColor) {
       [UISearchBar appearanceWhenContainedIn:[controller class], nil].tintColor = self.searchBarTintColor;
    }

    if (self.activityIndicatorColor) {
        [UIActivityIndicatorView appearanceWhenContainedIn:[controller class], nil].color = self.activityIndicatorColor;
    }

    if (self.progressCircleTrackColor) {
        [KAProgressLabel appearance].customTrackColor = self.progressCircleTrackColor;
    }

    if (self.progressCircleProgressColor) {
        [KAProgressLabel appearance].customProgressColor = self.progressCircleProgressColor;
    }
}
#pragma clang diagnostic pop

+ (void)applyDefaultToController:(UIResponder *)controller {
    [UICollectionView appearanceWhenContainedIn:[controller class], nil].backgroundColor = [UIColor whiteColor];
    [FSCollectionViewCell appearance].backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
}

+ (FSTheme *)filestackTheme {
    FSTheme *theme = [[FSTheme alloc] init];
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1]};

    theme.navigationBarStyle = UIBarStyleBlack;
    theme.navigationBarBackgroundColor = [UIColor colorWithRed:0.09 green:0.115 blue:0.17 alpha:1];
    theme.navigationBarTintColor = [UIColor colorWithRed:0.55 green:0.6 blue:0.63 alpha:1];
    theme.headerFooterViewTintColor = [UIColor colorWithRed:0.16 green:0.18 blue:0.22 alpha:1];
    theme.headerFooterViewTextColor = [UIColor whiteColor];
    theme.tableViewBackgroundColor = [UIColor colorWithRed:0.18 green:0.23 blue:0.27 alpha:1];
    theme.tableViewSeparatorColor = [UIColor colorWithRed:0.55 green:0.6 blue:0.63 alpha:1];
    theme.tableViewCellBackgroundColor = [UIColor colorWithRed:0.18 green:0.23 blue:0.27 alpha:1];
    theme.tableViewCellTextColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    theme.tableViewCellSelectedBackgroundColor = [UIColor colorWithRed:0.95 green:1 blue:1 alpha:1];
    theme.tableViewCellSelectedTextColor = [UIColor colorWithRed:0.16 green:0.18 blue:0.22 alpha:1];
    theme.collectionViewBackgroundColor = [UIColor colorWithRed:0.18 green:0.23 blue:0.27 alpha:1];
    theme.collectionViewCellBackgroundColor = [UIColor colorWithRed:0.18 green:0.23 blue:0.27 alpha:1];
    theme.collectionViewCellBorderColor = [UIColor colorWithRed:0 green:0.6 blue:0.55 alpha:1];
    theme.collectionViewCellTitleTextColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    theme.uploadButtonTextColor = [UIColor whiteColor];
    theme.uploadButtonBackgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0.55 alpha:1];
    theme.cellIconTintColor = [UIColor colorWithRed:0 green:0.6 blue:0.55 alpha:1];
    theme.tableViewCellImageViewBorderColor = [UIColor colorWithRed:0.16 green:0.18 blue:0.22 alpha:1];
    theme.refreshControlTintColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    theme.refreshControlAttributedTitle = [[NSAttributedString alloc] initWithString:@"Syncing data..." attributes:attributes];
    theme.searchBarBackgroundColor = [UIColor colorWithRed:0.16 green:0.18 blue:0.22 alpha:1];
    theme.searchBarTintColor = [UIColor colorWithRed:0 green:0.6 blue:0.55 alpha:1];
    theme.activityIndicatorColor = [UIColor colorWithRed:0.55 green:0.6 blue:0.63 alpha:1];
    theme.progressCircleTrackColor = [UIColor colorWithRed:0.18 green:0.23 blue:0.27 alpha:1.00];
    theme.progressCircleProgressColor = [UIColor colorWithRed:0.11 green:0.60 blue:0.55 alpha:1.00];

    return theme;
}

@end

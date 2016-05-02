//
//  FSThemeTests.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 29/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSTheme.h"
#import "FSTableViewCell.h"
#import "UILabel+Appearance.h"
#import "FSCollectionViewCell.h"
#import "FSBarButtonItem.h"
#import "KAProgressLabel.h"
#import "FSSourceTableViewController.h"

@interface FSThemeTests : XCTestCase

@end

@implementation FSThemeTests

- (void)setUp {
    [super setUp];

}

- (void)tearDown {

    [super tearDown];
}

- (void)testTheme {
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1]};
    NSAttributedString *refreshControlAttributedTitle = [[NSAttributedString alloc] initWithString:@"Syncing data..." attributes:attributes];
    UIBarStyle navigationBarStyle = UIBarStyleBlack;
    UIColor *navigationBarBackgroundColor = [UIColor colorWithRed:0.09 green:0.115 blue:0.17 alpha:1];
    UIColor *navigationBarTintColor = [UIColor colorWithRed:0.55 green:0.6 blue:0.63 alpha:1];
    UIColor *headerFooterViewTintColor = [UIColor colorWithRed:0.16 green:0.18 blue:0.22 alpha:1];
    UIColor *headerFooterViewTextColor = [UIColor whiteColor];
    UIColor *tableViewBackgroundColor = [UIColor colorWithRed:0.18 green:0.23 blue:0.27 alpha:1];
    UIColor *tableViewSeparatorColor = [UIColor colorWithRed:0.55 green:0.6 blue:0.63 alpha:1];
    UIColor *tableViewCellBackgroundColor = [UIColor colorWithRed:0.18 green:0.23 blue:0.27 alpha:1];
    UIColor *tableViewCellTextColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    UIColor *tableViewCellSelectedBackgroundColor = [UIColor colorWithRed:0.95 green:1 blue:1 alpha:1];
    UIColor *tableViewCellSelectedTextColor = [UIColor colorWithRed:0.16 green:0.18 blue:0.22 alpha:1];
    UIColor *collectionViewBackgroundColor = [UIColor colorWithRed:0.18 green:0.23 blue:0.27 alpha:1];
    UIColor *collectionViewCellBackgroundColor = [UIColor colorWithRed:0.18 green:0.23 blue:0.27 alpha:1];
    UIColor *collectionViewCellBorderColor = [UIColor colorWithRed:0 green:0.6 blue:0.55 alpha:1];
    UIColor *collectionViewCellTitleTextColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    UIColor *uploadButtonTextColor = [UIColor whiteColor];
    UIColor *uploadButtonBackgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0.55 alpha:1];
    UIColor *cellIconTintColor = [UIColor colorWithRed:0 green:0.6 blue:0.55 alpha:1];
    UIColor *tableViewCellImageViewBorderColor = [UIColor colorWithRed:0.16 green:0.18 blue:0.22 alpha:1];
    UIColor *refreshControlTintColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    UIColor *searchBarBackgroundColor = [UIColor colorWithRed:0.16 green:0.18 blue:0.22 alpha:1];
    UIColor *searchBarTintColor = [UIColor colorWithRed:0 green:0.6 blue:0.55 alpha:1];
    UIColor *activityIndicatorColor = [UIColor colorWithRed:0.55 green:0.6 blue:0.63 alpha:1];
    UIColor *progressCircleTrackColor = [UIColor colorWithRed:0.18 green:0.23 blue:0.27 alpha:1.00];
    UIColor *progressCircleProgressColor = [UIColor colorWithRed:0.11 green:0.60 blue:0.55 alpha:1.00];

    FSTheme *theme = [[FSTheme alloc] init];

    theme.navigationBarStyle = navigationBarStyle;
    theme.navigationBarBackgroundColor = navigationBarBackgroundColor;
    theme.navigationBarTintColor = navigationBarTintColor;
    theme.headerFooterViewTintColor = headerFooterViewTintColor;
    theme.headerFooterViewTextColor = headerFooterViewTextColor;
    theme.tableViewBackgroundColor = tableViewBackgroundColor;
    theme.tableViewSeparatorColor = tableViewSeparatorColor;
    theme.tableViewCellBackgroundColor = tableViewCellBackgroundColor;
    theme.tableViewCellTextColor = tableViewCellTextColor;
    theme.tableViewCellSelectedBackgroundColor = tableViewCellSelectedBackgroundColor;
    theme.tableViewCellSelectedTextColor = tableViewCellSelectedTextColor;
    theme.collectionViewBackgroundColor = collectionViewBackgroundColor;
    theme.collectionViewCellBackgroundColor = collectionViewCellBackgroundColor;
    theme.collectionViewCellBorderColor = collectionViewCellBorderColor;
    theme.collectionViewCellTitleTextColor = collectionViewCellTitleTextColor;
    theme.uploadButtonTextColor = uploadButtonTextColor;
    theme.uploadButtonBackgroundColor = uploadButtonBackgroundColor;
    theme.cellIconTintColor = cellIconTintColor;
    theme.tableViewCellImageViewBorderColor = tableViewCellImageViewBorderColor;
    theme.refreshControlTintColor = refreshControlTintColor;
    theme.refreshControlAttributedTitle = refreshControlAttributedTitle;
    theme.searchBarBackgroundColor = searchBarBackgroundColor;
    theme.searchBarTintColor = searchBarTintColor;
    theme.activityIndicatorColor = activityIndicatorColor;
    theme.progressCircleTrackColor = progressCircleTrackColor;
    theme.progressCircleProgressColor = progressCircleProgressColor;

    UIViewController *controller = [[FSSourceTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navController = [[UINavigationController alloc] init];

    [theme applyToController:controller];
    [theme applyToController:navController];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    UIBarStyle controllerNavigationBarStyle = navController.navigationBar.barStyle;
    XCTAssertEqual(controllerNavigationBarStyle, theme.navigationBarStyle);

    UIColor *controllerNavigationBarBackgroundColor = navController.navigationBar.barTintColor;
    XCTAssertEqualObjects(controllerNavigationBarBackgroundColor, theme.navigationBarBackgroundColor);

    UIColor *controllerNavigationBarTintColor = navController.navigationBar.tintColor;
    XCTAssertEqualObjects(controllerNavigationBarTintColor, theme.navigationBarTintColor);

    UIColor *controllerHeaderFooterViewTintColor = [UITableViewHeaderFooterView appearanceWhenContainedIn:[controller class], nil].tintColor;
    XCTAssertEqualObjects(controllerHeaderFooterViewTintColor, theme.headerFooterViewTintColor);

    UIColor *controllerHeaderFooterViewTextColor = [UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], [controller class], nil].textColor;
    XCTAssertEqualObjects(controllerHeaderFooterViewTextColor, theme.headerFooterViewTextColor);

    UIColor *controllerTableViewBackgroundColor = [UITableView appearanceWhenContainedIn:[controller class], nil].backgroundColor;
    XCTAssertEqualObjects(controllerTableViewBackgroundColor, theme.tableViewBackgroundColor);

    UIColor *controllerTableViewSeparatorColor = [UITableView appearanceWhenContainedIn:[controller class], nil].separatorColor;
    XCTAssertEqualObjects(controllerTableViewSeparatorColor, theme.tableViewSeparatorColor);

    UIColor *controllerCollectionViewBackgroundColor = [UICollectionView appearanceWhenContainedIn:[controller class], nil].backgroundColor;
    XCTAssertEqualObjects(controllerCollectionViewBackgroundColor, theme.collectionViewBackgroundColor);

    UIColor *controllerCollectionViewCellBackgroundColor = [FSCollectionViewCell appearance].backgroundColor;
    XCTAssertEqualObjects(controllerCollectionViewCellBackgroundColor, theme.collectionViewCellBackgroundColor);

    UIColor *controllerCollectionViewCellBorderColor = [FSCollectionViewCell appearance].appearanceBorderColor;
    XCTAssertEqualObjects(controllerCollectionViewCellBorderColor, theme.collectionViewCellBorderColor);

    UIColor *controllerCollectionViewCellTitleTextColor = [FSCollectionViewCell appearance].appearanceTitleLabelTextColor;
    XCTAssertEqualObjects(controllerCollectionViewCellTitleTextColor, theme.collectionViewCellTitleTextColor);

    UIColor *controllerUploadButtonTextColor = [FSBarButtonItem appearance].normalTextColor;
    XCTAssertEqualObjects(controllerUploadButtonTextColor, theme.uploadButtonTextColor);

    UIColor *controllerUploadButtonBackgroundColor = [FSBarButtonItem appearance].backgroundColor;
    XCTAssertEqualObjects(controllerUploadButtonBackgroundColor, theme.uploadButtonBackgroundColor);

    UIColor *controllerCellIconTintColor = [UIImageView appearanceWhenContainedIn:[controller class], nil].tintColor;
    XCTAssertEqualObjects(controllerCellIconTintColor, theme.cellIconTintColor);

    UIColor *controllerTableViewCellImageViewBorderColor = [FSTableViewCell appearance].imageViewBorderColor;
    XCTAssertEqualObjects(controllerTableViewCellImageViewBorderColor, theme.tableViewCellImageViewBorderColor);

    UIColor *controllerSearchBarBackgroundColor = [UISearchBar appearanceWhenContainedIn:[controller class], nil].barTintColor;
    XCTAssertEqualObjects(controllerSearchBarBackgroundColor, theme.searchBarBackgroundColor);

    UIColor *controllerSearchBarTintColor = [UISearchBar appearanceWhenContainedIn:[controller class], nil].tintColor;
    XCTAssertEqualObjects(controllerSearchBarTintColor, theme.searchBarTintColor);

#pragma clang diagnostic pop
}

@end

//
//  UICollectionViewFlowLayout+FSPicker.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 01/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "UICollectionViewFlowLayout+FSPicker.h"

@implementation UICollectionViewFlowLayout (FSPicker)

- (void)calculateAndSetItemSizeReversed:(BOOL)reversed {
    CGFloat screenBoundsHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenBoundsWidth = [[UIScreen mainScreen] bounds].size.width;
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    NSUInteger itemsPerRowPortrait = 4;
    NSUInteger itemsPerRowLandscape = 7;
    NSUInteger totalSpacingPortrait = (itemsPerRowPortrait - 1) * 2;
    NSUInteger totalSpacingLandscape = (itemsPerRowLandscape - 1) * 2;
    CGFloat itemSize;

    if (isLandscape && reversed) {
        itemSize = (screenBoundsHeight - totalSpacingPortrait) / itemsPerRowPortrait;
    } else if (isLandscape && !reversed) {
        itemSize = (screenBoundsWidth - totalSpacingLandscape) / itemsPerRowLandscape;
    } else if (!isLandscape && reversed) {
        itemSize = (screenBoundsHeight - totalSpacingLandscape) / itemsPerRowLandscape;
    } else {
        itemSize = (screenBoundsWidth - totalSpacingPortrait) / itemsPerRowPortrait;
    }

    self.itemSize = CGSizeMake((int)itemSize, (int)itemSize);
}

@end

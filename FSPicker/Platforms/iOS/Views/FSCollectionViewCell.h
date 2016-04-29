//
//  FSCollectionViewCell.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 29/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, FSCollectionViewCellType) {
    FSCollectionViewCellTypeMedia,
    FSCollectionViewCellTypeDirectory,
    FSCollectionViewCellTypeFile,
    FSCollectionViewCellTypeLoad
};

@interface FSCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) NSURLSessionDataTask *imageTask;
@property (nonatomic, assign) NSUInteger taskHash;
@property (nonatomic, assign) FSCollectionViewCellType type;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIColor *appearanceBorderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIColor *appearanceTitleLabelTextColor UI_APPEARANCE_SELECTOR;

@end

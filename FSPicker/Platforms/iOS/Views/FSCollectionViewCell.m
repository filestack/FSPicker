//
//  FSCollectionViewCell.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 29/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSCollectionViewCell.h"

@implementation FSCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupTitleLabel];
        [self setupImageView];
        [self setupOverlayImageView];
        [self setupActivityIndicator];
    }

    return self;
}

- (void)setupTitleLabel {
    CGRect frame = CGRectMake(4, self.bounds.size.height - 20, self.bounds.size.width - 8, 14);
    self.titleLabel = [[UILabel alloc] initWithFrame:frame];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.hidden = YES;
    [self addSubview:self.titleLabel];
}

- (void)setupOverlayImageView {
    self.overlayImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.overlayImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.overlayImageView];
    [self bringSubviewToFront:self.overlayImageView];
}

- (void)setupImageView {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.imageView];
}

- (void)setupActivityIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.frame = CGRectMake((self.frame.size.width / 2) - 10, (self.frame.size.height / 2) - 10, 20, 20);
    self.activityIndicator.hidesWhenStopped = YES;
    [self addSubview:self.activityIndicator];
    [self bringSubviewToFront:self.activityIndicator];
}

- (void)setAppearanceBorderColor:(UIColor *)color {
    self.imageView.layer.borderColor = color.CGColor;
}

- (void)setAppearanceTitleLabelTextColor:(UIColor *)appearanceTitleLabelTextColor {
    self.titleLabel.textColor = appearanceTitleLabelTextColor;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    if (self.type != FSCollectionViewCellTypeMedia) {
        self.imageView.image = nil;
    }
}

@end

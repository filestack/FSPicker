//
//  FSListTableViewCell.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 17/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSListTableViewCell.h"
#import "FSTableViewCellTag.h"

@implementation FSListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.detailTextLabel.tag = FSTableViewCellTagDetail;
    }

    return self;
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = selectedBackgroundColor;
    self.selectedBackgroundView = bgView;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat labelWidth = self.frame.size.width - 100;

    self.imageView.frame = CGRectMake(16, 6, 32, 32);
    self.textLabel.frame = CGRectMake(62, 4, labelWidth, 20);
    self.detailTextLabel.frame = CGRectMake(62, 22, labelWidth, 20);
}

@end

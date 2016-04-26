//
//  FSSourceTableViewCell.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 03/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSourceTableViewCell.h"
#import "FSTableViewCellTag.h"

@implementation FSSourceTableViewCell

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

@end

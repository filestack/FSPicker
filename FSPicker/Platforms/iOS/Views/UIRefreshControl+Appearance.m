//
//  UIRefreshControl+Appearance.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 09/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "UIRefreshControl+Appearance.h"

@implementation UIRefreshControl (Appearance)

- (void)setCustomAttributedTitle:(NSAttributedString *)customAttributedTitle {
    self.attributedTitle = customAttributedTitle;
}

@end

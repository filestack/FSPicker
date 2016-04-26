//
//  FSImage.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 16/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSImage.h"

@implementation FSImage

+ (UIImage *)iconNamed:(NSString *)iconName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    return [[UIImage imageNamed:iconName
                       inBundle:bundle
  compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)cellSelectedOverlay {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    return [UIImage imageNamed:@"selected-overlay" inBundle:bundle compatibleWithTraitCollection:nil];
}

@end

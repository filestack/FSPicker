//
//  UIImage+Scale.m
//  FSPicker
//
//  Created by Ruben Nine on 30/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)

- (UIImage *)scaledToSize:(CGSize)newSize honoringScalingFactor:(BOOL)honorScaleFactor {

    CGFloat scale = honorScaleFactor ? 0.0 : 1.0;

    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (UIImage *)scaledToSize:(CGSize)newSize {

    return [self scaledToSize:newSize honoringScalingFactor:YES];
}

@end

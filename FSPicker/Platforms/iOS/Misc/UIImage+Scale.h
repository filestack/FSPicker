//
//  UIImage+Scale.h
//  FSPicker
//
//  Created by Ruben Nine on 30/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)

- (UIImage *)scaledToSize:(CGSize)newSize honoringScalingFactor:(BOOL)honorScaleFactor;
- (UIImage *)scaledToSize:(CGSize)newSize;

@end

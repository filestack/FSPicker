//
//  FSImageFetcher.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 29/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSImageFetcher.h"

@implementation FSImageFetcher

+ (void)imageForAsset:(PHAsset *)asset withCachingImageManager:(PHCachingImageManager *)cachingManager thumbSize:(CGFloat)thumbSize contentMode:(PHImageContentMode)contentMode imageResult:(void (^)(UIImage *image))imageResult {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize scaledThumbSize = CGSizeMake(thumbSize * scale, thumbSize * scale);
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
    CGFloat cropSideLength = MIN(asset.pixelWidth, asset.pixelHeight);
#pragma GCC diagnostic pop
    CGRect square = CGRectMake(0, 0, cropSideLength, cropSideLength);
    CGRect cropRect = CGRectApplyAffineTransform(square, CGAffineTransformMakeScale(1.0 / asset.pixelWidth, 1.0 / asset.pixelHeight));

    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    requestOptions.networkAccessAllowed = YES;
    requestOptions.normalizedCropRect = cropRect;

    [cachingManager requestImageForAsset:asset
                              targetSize:scaledThumbSize
                             contentMode:contentMode
                                 options:requestOptions
                           resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        imageResult(result);
    }];
}

@end

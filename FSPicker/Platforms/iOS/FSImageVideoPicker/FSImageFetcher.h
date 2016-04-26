//
//  FSImageFetcher.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 29/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import Foundation;
@import Photos;

@interface FSImageFetcher : NSObject

+ (void)imageForAsset:(PHAsset *)asset withCachingImageManager:(PHCachingImageManager *)cachingManager thumbSize:(CGFloat)thumbSize contentMode:(PHImageContentMode)contentMode imageResult:(void (^)(UIImage *image))imageResult;

@end

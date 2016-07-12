//
//  FSUploader.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 14/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Filestack/Filestack.h>
#import <Filestack/Filestack+FSPicker.h>
#import "UIImage+Rotate.h"
#import "FSSource.h"
#import "FSConfig.h"
#import "FSSession.h"
#import "FSUploader.h"
#import "FSContentItem.h"
@import Photos;
@interface FSUploader ()

@property (nonatomic, strong) FSConfig *config;
@property (nonatomic, strong) FSSource *source;
@property (nonatomic, strong) NSMutableArray <FSBlob *> *blobsArray;

@end

@implementation FSUploader

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source {
    if ((self = [super init])) {
        _config = config;
        _source = source;
        _blobsArray = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)uploadCloudItems:(NSArray<FSContentItem *> *)items {
    NSUInteger totalNumberOfItems = items.count;
    NSUInteger __block uploadedItems = 0;

    FSSession *session = [[FSSession alloc] initWithConfig:self.config mimeTypes:self.source.mimeTypes];

    for (FSContentItem *item in items) {
        NSDictionary *parameters = [session toQueryParametersWithFormat:@"fpurl"];

        [Filestack pickFSURL:item.linkPath parameters:parameters completionHandler:^(FSBlob *blob, NSError *error) {
            uploadedItems++;

            if (blob) {
                [self.blobsArray addObject:blob];
            }

            if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadProgress:addToTotalProgress:)]) {
                float currentProgress = (float)uploadedItems / totalNumberOfItems;
                [self.uploadModalDelegate fsUploadProgress:currentProgress addToTotalProgress:NO];
            }

            [self messageDelegateWithBlob:blob error:error];

            if (uploadedItems == totalNumberOfItems) {
                if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:completion:)]) {
                    [self.uploadModalDelegate fsUploadFinishedWithBlobs:nil completion:^{
                        if ([self.pickerDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:completion:)]) {
                            [self.pickerDelegate fsUploadFinishedWithBlobs:self.blobsArray completion:nil];
                        }
                    }];
                }
            }
        }];
    }
}

- (void)uploadCameraItemWithInfo:(NSDictionary<NSString *,id> *)info {
    if (info[UIImagePickerControllerOriginalImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        UIImage *rotatedImage = [image fixRotation];
        NSData *imageData = UIImageJPEGRepresentation(rotatedImage, 0.95);
        NSString *fileName = [NSString stringWithFormat:@"Image_%@.jpg", [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
        NSCharacterSet *dateFormat = [NSCharacterSet characterSetWithCharactersInString:@"/: "];
        fileName = [[fileName componentsSeparatedByCharactersInSet:dateFormat] componentsJoinedByString:@"-"];

        [self uploadCameraItem:imageData fileName:fileName];
    } else if (info[UIImagePickerControllerMediaURL]) {
        NSURL *fileURL = info[UIImagePickerControllerMediaURL];
        NSString *fileName = fileURL.lastPathComponent;
        NSData *videoData = [NSData dataWithContentsOfURL:fileURL];

        [self uploadCameraItem:videoData fileName:fileName];
    }
}

- (void)uploadCameraItem:(NSData *)itemData fileName:(NSString *)fileName {
    BOOL delegateRespondsToUploadProgress = [self.uploadModalDelegate respondsToSelector:@selector(fsUploadProgress:addToTotalProgress:)];

    Filestack *filestack = [[Filestack alloc] initWithApiKey:self.config.apiKey];
    FSStoreOptions *storeOptions = [self.config.storeOptions copy];

    if (!storeOptions) {
        storeOptions = [[FSStoreOptions alloc] init];
    }

    storeOptions.fileName = fileName;
    storeOptions.mimeType = nil;

    [filestack store:itemData withOptions:storeOptions progress:^(NSProgress *uploadProgress) {
        if (delegateRespondsToUploadProgress) {
            [self.uploadModalDelegate fsUploadProgress:uploadProgress.fractionCompleted addToTotalProgress:NO];
        }
    } completionHandler:^(FSBlob *blob, NSError *error) {
        [self messageDelegateWithBlob:blob error:error];

        if (blob) {
            [self messageDelegateLocalUploadFinished];
        } else {
            [self messageDelegateWithBlob:nil error:error];
        }

        if (delegateRespondsToUploadProgress) {
            [self.uploadModalDelegate fsUploadProgress:1.0 addToTotalProgress:NO];
        }
    }];
}

- (void)uploadLocalItems:(NSArray<PHAsset *> *)items {
    BOOL delegateRespondsToUploadProgress = [self.uploadModalDelegate respondsToSelector:@selector(fsUploadProgress:addToTotalProgress:)];
    NSUInteger totalNumberOfItems = items.count;
    NSUInteger __block uploadedItems = 0;

    Filestack *filestack = [[Filestack alloc] initWithApiKey:self.config.apiKey];
    FSStoreOptions *storeOptions = [self.config.storeOptions copy];

    if (!storeOptions) {
        storeOptions = [[FSStoreOptions alloc] init];
    }

    storeOptions.mimeType = nil;

    PHVideoRequestOptions *options=[[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;

    for (PHAsset *item in items) {
        double __block progressToAdd = 0.0;
        double __block currentItemProgress = 0.0;

        if (item.mediaType == PHAssetMediaTypeImage) {
            [self uploadLocalImageAsset:item usingFilestack:filestack storeOptions:storeOptions progress:^(NSProgress *uploadProgress) {
                if (delegateRespondsToUploadProgress) {
                    progressToAdd = uploadProgress.fractionCompleted * (1.0 / totalNumberOfItems) - currentItemProgress;
                    currentItemProgress = uploadProgress.fractionCompleted * (1.0 / totalNumberOfItems);
                    [self.uploadModalDelegate fsUploadProgress:progressToAdd addToTotalProgress:YES];
                }
            } completionHandler:^(FSBlob *blob, NSError *error) {
                uploadedItems++;

                [self messageDelegateWithBlob:blob error:error];

                if (uploadedItems == totalNumberOfItems) {
                    [self messageDelegateLocalUploadFinished];
                }
            }];
        } else if (item.mediaType == PHAssetMediaTypeVideo) {
            [self uploadLocalVideoAsset:item usingFilestack:filestack storeOptions:storeOptions progress:^(NSProgress *uploadProgress) {
                if (delegateRespondsToUploadProgress) {
                    progressToAdd = uploadProgress.fractionCompleted * (1.0 / totalNumberOfItems) - currentItemProgress;
                    currentItemProgress = uploadProgress.fractionCompleted * (1.0 / totalNumberOfItems);
                    [self.uploadModalDelegate fsUploadProgress:progressToAdd addToTotalProgress:YES];
                }
            } completionHandler:^(FSBlob *blob, NSError *error) {
                uploadedItems++;

                [self messageDelegateWithBlob:blob error:error];

                if (uploadedItems == totalNumberOfItems) {
                    [self messageDelegateLocalUploadFinished];
                }
            }];
        }
    }
}

- (void)uploadLocalImageAsset:(PHAsset *)asset
               usingFilestack:(Filestack *)filestack
                 storeOptions:(FSStoreOptions *)storeOptions
                     progress:(void (^)(NSProgress *uploadProgress))progress
            completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {

    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
        NSURL *imageURL = info[@"PHImageFileURLKey"];
        NSString *fileName = imageURL.lastPathComponent;
        storeOptions.fileName = fileName;

        [filestack store:imageData withOptions:storeOptions progress:^(NSProgress *uploadProgress) {
            progress(uploadProgress);
        } completionHandler:^(FSBlob *blob, NSError *error) {
            completionHandler(blob, error);
        }];
    }];
}

- (void)uploadLocalVideoAsset:(PHAsset *)asset
               usingFilestack:(Filestack *)filestack
                 storeOptions:(FSStoreOptions *)storeOptions
                     progress:(void (^)(NSProgress *uploadProgress))progress
            completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {

    PHVideoRequestOptions *options=[[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;

    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            NSURL *URL = ((AVURLAsset *)asset).URL;
            NSData *data = [NSData dataWithContentsOfURL:URL];
            NSString *fileName = URL.lastPathComponent;
            storeOptions.fileName = fileName;

            [filestack store:data withOptions:storeOptions progress:^(NSProgress *uploadProgress) {
                progress(uploadProgress);
            } completionHandler:^(FSBlob *blob, NSError *error) {
                completionHandler(blob, error);
            }];
        }
    }];
}

- (void)messageDelegateLocalUploadFinished {
    if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadProgress:addToTotalProgress:)]) {
        [self.uploadModalDelegate fsUploadProgress:1.0 addToTotalProgress:NO];
    }

    if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:completion:)]) {
        [self.uploadModalDelegate fsUploadFinishedWithBlobs:nil completion:^{
            if ([self.pickerDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:completion:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pickerDelegate fsUploadFinishedWithBlobs:self.blobsArray completion:nil];
                });
            }
        }];
    }
}

- (void)messageDelegateWithBlob:(FSBlob *)blob error:(NSError *)error {
    if (blob) {
        [self.blobsArray addObject:blob];

        if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadComplete:)]) {
            [self.uploadModalDelegate fsUploadComplete:blob];
        }

        if ([self.pickerDelegate respondsToSelector:@selector(fsUploadComplete:)]) {
            [self.pickerDelegate fsUploadComplete:blob];
        }
    } else {
        if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadError:)]) {
            [self.uploadModalDelegate fsUploadError:error];
        }

        if ([self.pickerDelegate respondsToSelector:@selector(fsUploadError:)]) {
            [self.pickerDelegate fsUploadError:error];
        }
    }
}

@end

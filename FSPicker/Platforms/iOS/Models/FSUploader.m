//
//  FSUploader.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 14/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Filestack/Filestack.h>
#import <Filestack/Filestack+FSPicker.h>
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

                if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadProgress:addToTotalProgress:)]) {
                    float currentProgress = (float)uploadedItems / totalNumberOfItems;
                    [self.uploadModalDelegate fsUploadProgress:currentProgress addToTotalProgress:NO];
                }
            }

            [self messageDelegateWithBlob:blob error:error];

            if (uploadedItems == totalNumberOfItems) {
                if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:)]) {
                    [self.uploadModalDelegate fsUploadFinishedWithBlobs:self.blobsArray];
                }

                if ([self.pickerDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:)]) {
                    [self.pickerDelegate fsUploadFinishedWithBlobs:self.blobsArray];
                }
            }
        }];
    }
}

- (void)uploadCameraItem:(NSData *)itemData fileName:(NSString *)fileName {
    BOOL delegateRespondsToUploadProgress = [self.uploadModalDelegate respondsToSelector:@selector(fsUploadProgress:addToTotalProgress:)];

    Filestack *filestack = [[Filestack alloc] initWithApiKey:self.config.apiKey];
    FSStoreOptions *storeOptions = [self.config.storeOptions copy];

    storeOptions.fileName = fileName;
    storeOptions.mimeType = nil;

    [filestack store:itemData withOptions:storeOptions progress:^(NSProgress *uploadProgress) {
        if (delegateRespondsToUploadProgress) {
            [self.uploadModalDelegate fsUploadProgress:uploadProgress.fractionCompleted addToTotalProgress:NO];
        }
    } completionHandler:^(FSBlob *blob, NSError *error) {
        [self messageDelegateWithBlob:blob error:error];

        if (blob) {
            if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:)]) {
                [self.uploadModalDelegate fsUploadFinishedWithBlobs:@[blob]];
            }

            if ([self.pickerDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:)]) {
                [self.pickerDelegate fsUploadFinishedWithBlobs:@[blob]];
            }
        } else {
            if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadError:)]) {
                [self.uploadModalDelegate fsUploadError:error];
            }

            if ([self.pickerDelegate respondsToSelector:@selector(fsUploadError:)]) {
                [self.pickerDelegate fsUploadError:error];
            }
        }

        if (delegateRespondsToUploadProgress) {
            [self.uploadModalDelegate fsUploadProgress:1.0 addToTotalProgress:NO];
        }
    }];
}

- (void)uploadLocalItems:(NSArray<PHAsset *> *)items {
    BOOL delegateRespondsToUploadProgress = [self.uploadModalDelegate respondsToSelector:@selector(fsUploadProgress:addToTotalProgress:)];
    NSUInteger totalNumberOfItems = items.count;
    NSUInteger __block uploadedItems = 1;

    Filestack *filestack = [[Filestack alloc] initWithApiKey:self.config.apiKey];
    FSStoreOptions *storeOptions = [self.config.storeOptions copy];
    storeOptions.mimeType = nil;

    PHVideoRequestOptions *options=[[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;

    for (PHAsset *item in items) {
        double __block progressToAdd = 0.0;
        double __block currentItemProgress = 0.0;

        if (item.mediaType == PHAssetMediaTypeImage) {
            [[PHImageManager defaultManager] requestImageDataForAsset:item options:nil resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
                NSURL *imageURL = [info objectForKey:@"PHImageFileURLKey"];
                NSString *fileName = imageURL.lastPathComponent;
                storeOptions.fileName = fileName;

                [filestack store:imageData withOptions:storeOptions progress:^(NSProgress *uploadProgress) {
                    if (delegateRespondsToUploadProgress) {
                        progressToAdd = uploadProgress.fractionCompleted * (1.0 / totalNumberOfItems) - currentItemProgress;
                        currentItemProgress = uploadProgress.fractionCompleted * (1.0 / totalNumberOfItems);
                        [self.uploadModalDelegate fsUploadProgress:progressToAdd addToTotalProgress:YES];
                    }
                } completionHandler:^(FSBlob *blob, NSError *error) {
                    uploadedItems++;

                    if (blob) {
                        [self.blobsArray addObject:blob];
                    }

                    [self messageDelegateWithBlob:blob error:error];

                    if (uploadedItems >= totalNumberOfItems) {
                        [self messageDelegateLocalUploadFinished];
                    }
                }];
            }];
        } else if (item.mediaType == PHAssetMediaTypeVideo) {
            [[PHImageManager defaultManager] requestAVAssetForVideo:item options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    NSURL *URL = ((AVURLAsset *)asset).URL;
                    NSData *data = [NSData dataWithContentsOfURL:URL];
                    NSString *fileName = URL.lastPathComponent;
                    storeOptions.fileName = fileName;

                    [filestack store:data withOptions:storeOptions progress:^(NSProgress *uploadProgress) {
                        if (delegateRespondsToUploadProgress) {
                            progressToAdd = uploadProgress.fractionCompleted * (1.0 / totalNumberOfItems) - currentItemProgress;
                            currentItemProgress = uploadProgress.fractionCompleted * (1.0 / totalNumberOfItems);
                            [self.uploadModalDelegate fsUploadProgress:progressToAdd addToTotalProgress:YES];
                        }
                    } completionHandler:^(FSBlob *blob, NSError *error) {
                        uploadedItems++;

                        if (blob) {
                            [self.blobsArray addObject:blob];
                        }

                        [self messageDelegateWithBlob:blob error:error];

                        if (uploadedItems >= totalNumberOfItems) {
                            [self messageDelegateLocalUploadFinished];
                        }
                    }];
                }
            }];
        }
    }
}

- (void)messageDelegateLocalUploadFinished {
    if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:)]) {
        [self.uploadModalDelegate fsUploadFinishedWithBlobs:self.blobsArray];
    }

    if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadProgress:addToTotalProgress:)]) {
        [self.uploadModalDelegate fsUploadProgress:1.0 addToTotalProgress:NO];
    }

    if ([self.pickerDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:)]) {
        [self.pickerDelegate fsUploadFinishedWithBlobs:self.blobsArray];
    }
}

- (void)messageDelegateWithBlob:(FSBlob *)blob error:(NSError *)error {
    if (blob) {
        if ([self.pickerDelegate respondsToSelector:@selector(fsUploadComplete:)]) {
            [self.pickerDelegate fsUploadComplete:blob];
        }

        if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadComplete:)]) {
            [self.uploadModalDelegate fsUploadComplete:blob];
        }
    } else {
        if ([self.pickerDelegate respondsToSelector:@selector(fsUploadError:)]) {
            [self.pickerDelegate fsUploadError:error];
        }

        if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadError:)]) {
            [self.uploadModalDelegate fsUploadError:error];
        }
    }
}

@end

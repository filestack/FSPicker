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
#import "FSDownloader.h"
@import Photos;

@import MobileCoreServices;
#import "GTLRBase64.h"

#import "GTMSessionFetcher.h"
#import "GTMSessionFetcherService.h"

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
    
    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive]
        || [self.source.identifier isEqualToString:FSSourcePicasa]) {
        [self uploadGoogleServiceItems:items];
        return;
    }
    
    if ([self.source.identifier isEqualToString:FSSourceGmail]) {
        [self uploadGmailItems:items];
        return;
    }
    
    NSUInteger totalNumberOfItems = items.count;
    NSUInteger __block uploadedItems = 0;
    FSDownloader *downloader;
    FSSession *session = [[FSSession alloc] initWithConfig:self.config mimeTypes:self.source.mimeTypes];

    // We have to upload AND download the item.
    if (self.config.shouldDownload) {
        downloader = [[FSDownloader alloc] init];
        totalNumberOfItems *= 2;
    }

    for (FSContentItem *item in items) {
        NSDictionary *parameters = [session toQueryParametersWithFormat:@"fpurl"];

        [Filestack pickFSURL:item.linkPath parameters:parameters completionHandler:^(FSBlob *blob, NSError *error) {
            uploadedItems++;
            // We won't download if there is an error, but have to "mark" the item as finished.
            if (self.config.shouldDownload && error) {
                uploadedItems++;
                [self messageDelegateWithBlob:blob error:error];
            }

            if (self.config.shouldDownload && !error) {
                // Downloader will modify the blob, setting internalURL on successful download.
                [downloader download:blob security:self.config.storeOptions.security completionHandler:^(NSString *fileURL, NSError *error) {
                    uploadedItems++;
                    blob.internalURL = fileURL;

                    [self updateProgress:uploadedItems total:totalNumberOfItems];
                    [self messageDelegateWithBlob:blob error:error];

                    if (uploadedItems == totalNumberOfItems) {
                        [self finishUpload];
                    }
                }];
            }

            [self updateProgress:uploadedItems total:totalNumberOfItems];

            if (!self.config.shouldDownload) {
                [self messageDelegateWithBlob:blob error:error];
            }

            if (uploadedItems == totalNumberOfItems) {
                [self finishUpload];
            }
        }];
    }
}

- (void)uploadGoogleServiceItems:(NSArray<FSContentItem *> *)items {
    NSUInteger totalNumberOfItems = items.count;
    NSUInteger __block uploadedItems = 0;
    
    Filestack *filestack = [[Filestack alloc] initWithApiKey:self.config.apiKey];

    
    // We have to upload AND download the item.
    totalNumberOfItems *= 2;

    
    for (FSContentItem *item in items) {
        
        NSString* convertedMIMEType = [self convertedGoogleMIMEType:item.mimeType];
        NSString* likelyExtension = [self extensionForMIMEType:convertedMIMEType];

        
        GTLRQuery * query;
        if (item.fileExtension || item.fullFileExtension) {
            query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:item.linkPath];
        }else{
            query = [GTLRDriveQuery_FilesExport queryForMediaWithFileId:item.linkPath
                                                            mimeType:convertedMIMEType];
        }
        
        //@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        NSURLRequest *downloadRequest = [self.config.service requestForQuery:query];
        GTMSessionFetcher *fetcher = [self.config.service.fetcherService fetcherWithRequest:downloadRequest];
        
        [fetcher setCommentWithFormat:@"Downloading %@", item.fileName];
        
        NSString *uuidFileName = [NSString stringWithFormat:@"%@_%@", item.fileName, item.linkPath];
        NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *fileURL = [tmpDirURL URLByAppendingPathComponent:uuidFileName];
        
        fetcher.destinationFileURL = fileURL;
        
        NSLog(@"%@%@", @"Uploading ", fileURL);
        [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
            uploadedItems++;
            NSLog(@"%@%@", @"Uploaded ", fileURL);

            FSBlob* blob = [[FSBlob alloc] initWithURL:fetcher.destinationFileURL.absoluteString];
            blob.internalURL = fetcher.destinationFileURL.absoluteString;
                        
            if (error == nil) {
                NSLog(@"Download succeeded.");
                
                FSStoreOptions *storeOptions = [self.config.storeOptions copy];
                
                if (!storeOptions) {
                    storeOptions = [[FSStoreOptions alloc] init];
                }
                
                storeOptions.mimeType = item.mimeType;
                
                if (item.fileExtension == nil && item.fullFileExtension == nil && likelyExtension) {
                    storeOptions.fileName = [item.fileName stringByAppendingFormat:@".%@", likelyExtension];
                }else{
                    storeOptions.fileName = item.fileName;
                }
                
                [self uploadLocalItem:item
                         localFileURL:fileURL
                       usingFilestack:filestack
                         storeOptions:storeOptions
                             progress:^(NSProgress *uploadProgress) {
                                 
                             }
                    completionHandler:^(FSBlob *blob, NSError *error) {
                        uploadedItems++;
                        
                        blob.internalURL = fileURL.absoluteString;
                        
                        [self updateProgress:uploadedItems total:totalNumberOfItems];
                        [self messageDelegateWithBlob:blob error:error];
                        
                        if (!self.config.shouldDownload) {
                            //! Remove uploaded file
                            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
                        }
                        
                        if (uploadedItems == totalNumberOfItems) {
                            [self finishUpload];
                        }

                    }];
            }else{                
                [self messageDelegateWithBlob:blob error:error];
                
                //! Check finish even if error
                uploadedItems++;
                [self updateProgress:uploadedItems total:totalNumberOfItems];
                
                if (uploadedItems == totalNumberOfItems) {
                    [self finishUpload];
                }
            }
            
            [self updateProgress:uploadedItems total:totalNumberOfItems];
            
            if (uploadedItems == totalNumberOfItems) {
                [self finishUpload];
            }
        }];
    
    }
}

- (void)uploadGmailItems:(NSArray<FSContentItem *> *)items {
    NSUInteger totalNumberOfItems = items.count;
    NSUInteger __block uploadedItems = 0;
    
    Filestack *filestack = [[Filestack alloc] initWithApiKey:self.config.apiKey];
    
    
    // We have to upload AND download the item.
    totalNumberOfItems *= 2;
    
    
    for (FSContentItem *item in items) {
        
        
        
        GTLRGmailQuery_UsersMessagesAttachmentsGet* query1 = [GTLRGmailQuery_UsersMessagesAttachmentsGet queryWithUserId:@"me" messageId:item.messageId identifier:item.attachmentId];
        
        [self.config.gmailService executeQuery:query1
                             completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket,
                                                 GTLRGmail_MessagePartBody* object,
                                                 NSError * _Nullable callbackError) {
                                 uploadedItems++;

                                 NSString *uuidFileName = [NSString stringWithFormat:@"%@_%@_%@", item.fileName, item.messageId, [[NSUUID UUID] UUIDString]];
                                 NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                                 NSURL *fileURL = [tmpDirURL URLByAppendingPathComponent:uuidFileName];
                                 NSLog(@"%@%@", @"Uploaded ", fileURL);

                                 NSData * data = GTLRDecodeWebSafeBase64(object.data);
                                 [data writeToFile:[fileURL path] atomically:YES];

                                 
                                 FSBlob* blob = [[FSBlob alloc] initWithURL:fileURL.absoluteString];
                                 blob.internalURL = fileURL.absoluteString;

                                 if (callbackError == nil) {
                                     NSLog(@"Download succeeded.");
                                     
                                     FSStoreOptions *storeOptions = [self.config.storeOptions copy];
                                     
                                     if (!storeOptions) {
                                         storeOptions = [[FSStoreOptions alloc] init];
                                     }
                                     
                                    storeOptions.mimeType = item.mimeType;
                                    storeOptions.fileName = item.fileName;
                                     
                                     [self uploadLocalItem:item
                                              localFileURL:fileURL
                                            usingFilestack:filestack
                                              storeOptions:storeOptions
                                                  progress:^(NSProgress *uploadProgress) {
                                                      
                                                  }
                                         completionHandler:^(FSBlob *blob, NSError *error) {
                                             uploadedItems++;
                                             
                                             blob.internalURL = fileURL.absoluteString;
                                             
                                             [self updateProgress:uploadedItems total:totalNumberOfItems];
                                             [self messageDelegateWithBlob:blob error:error];
                                             
                                             if (!self.config.shouldDownload) {
                                                 //! Remove uploaded file
                                                 [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
                                             }
                                             
                                             if (uploadedItems == totalNumberOfItems) {
                                                 [self finishUpload];
                                             }
                                             
                                         }];
                                 }else{
                                     [self messageDelegateWithBlob:blob error:callbackError];
                                     
                                     //! Check finish even if error
                                     uploadedItems++;
                                     [self updateProgress:uploadedItems total:totalNumberOfItems];
                                     
                                     if (uploadedItems == totalNumberOfItems) {
                                         [self finishUpload];
                                     }
                                 }
                                 
                                 [self updateProgress:uploadedItems total:totalNumberOfItems];
                                 
                                 if (uploadedItems == totalNumberOfItems) {
                                     [self finishUpload];
                                 }

                             }];
        
    }
}


- (NSString*)convertedGoogleMIMEType:(NSString*)mimeType{

    if ([mimeType isEqualToString:@"application/vnd.google-apps.document"]) {
        //return @"application/vnd.oasis.opendocument.text";
        return @"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
    }
    
    if ([mimeType isEqualToString:@"application/vnd.google-apps.spreadsheet"]) {
        //return @"application/x-vnd.oasis.opendocument.spreadsheet";
        return @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    }
    
    if ([mimeType isEqualToString:@"application/vnd.google-apps.drawing"]) {
        return @"image/png";
    }
    if ([mimeType isEqualToString:@"application/vnd.google-apps.presentation"]) {
        return @"application/pdf";
    }
    
    return nil;
}

- (NSString *)extensionForMIMEType:(NSString *)mimeType {
    // Try to convert a MIME type to an extension using the Mac's type identifiers.
    NSString *result = nil;
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
                                                            (__bridge CFStringRef)mimeType, NULL);
    if (uti) {
        CFStringRef cfExtn = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
        if (cfExtn) {
            result = CFBridgingRelease(cfExtn);
        }
        CFRelease(uti);
    }
    return result;
}


- (void)updateProgress:(NSUInteger)uploadedItems total:(NSUInteger)totalItems {
    if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadProgress:addToTotalProgress:)]) {
        float currentProgress = (float)uploadedItems / totalItems;
        [self.uploadModalDelegate fsUploadProgress:currentProgress addToTotalProgress:NO];
    }
}

- (void)finishUpload {
    if ([self.uploadModalDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:completion:)]) {
        [self.uploadModalDelegate fsUploadFinishedWithBlobs:nil completion:^{
            if ([self.pickerDelegate respondsToSelector:@selector(fsUploadFinishedWithBlobs:completion:)]) {
                [self.pickerDelegate fsUploadFinishedWithBlobs:self.blobsArray completion:nil];
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

- (void)uploadLocalItem:(FSContentItem *)item
                localFileURL:(NSURL*)fileURL
               usingFilestack:(Filestack *)filestack
                 storeOptions:(FSStoreOptions *)storeOptions
                     progress:(void (^)(NSProgress *uploadProgress))progress
            completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    
    NSData *fileData = [NSData dataWithContentsOfFile:fileURL.path];

    [filestack store:fileData withOptions:storeOptions progress:^(NSProgress *uploadProgress) {
        progress(uploadProgress);
    } completionHandler:^(FSBlob *blob, NSError *error) {
        completionHandler(blob, error);
    }];
    
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

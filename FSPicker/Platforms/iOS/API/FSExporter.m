//
//  FSExporter.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 19/05/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSExporter.h"
#import "FSConfig.h"
#import "FSSession.h"
#import "FSConfig+Private.h"
#import <Filestack/Filestack.h>
#import <Filestack/Filestack+FSPicker.h>

@interface FSExporter ()

@property (nonatomic, strong) FSConfig *config;

@end

@implementation FSExporter

- (instancetype)initWithConfig:(FSConfig *)config {
    if ((self = [super init])) {
        _config = config;
    }

    return self;
}

- (void)saveDataToCameraRoll {
    if (!self.config.data && !self.config.localDataURL) {
        if ([self.exporterDelegate respondsToSelector:@selector(fsExportComplete:)]) {
            [self.exporterDelegate fsExportComplete:nil];
        }
    }

    if (self.config.localDataURL) {
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:[self.config.localDataURL absoluteString]], nil, nil, nil);
    } else {
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:self.config.data], nil, nil, nil);
    }

    if ([self.exporterDelegate respondsToSelector:@selector(fsExportComplete:)]) {
        [self.exporterDelegate fsExportComplete:nil];
    }
}

- (void)saveDataNamed:(NSString *)name toPath:(NSString *)path {
    NSString *fileName = [self fileNameWithName:name];
    NSString *fileNameWithExtension = [self addExtensionToFileName:fileName];

    NSData *fileData = [self fileDataToExport];

    if (!fileData) {
        if ([self.progressModalDelegate respondsToSelector:@selector(fsExportError:)]) {
            [self.progressModalDelegate fsExportError:nil]; // Just to dismiss the progress modal.
        }

        return; // Early exit if neither data nor dataURL are present.
    }

    Filestack *filestack = [[Filestack alloc] initWithApiKey:self.config.apiKey];
    FSStoreOptions *storeOptions = [self.config.storeOptions copy];

    if (!storeOptions) {
        storeOptions = [[FSStoreOptions alloc] init];
    }

    storeOptions.fileName = fileNameWithExtension;
    storeOptions.mimeType = self.config.dataMimeType ?: nil;

    BOOL delegateRespondsToUploadProgress = [self.progressModalDelegate respondsToSelector:@selector(fsExportProgress:addToTotalProgress:)];

    [filestack store:fileData withOptions:storeOptions progress:^(NSProgress *uploadProgress) {
        if (delegateRespondsToUploadProgress) {
            [self.progressModalDelegate fsExportProgress:uploadProgress.fractionCompleted addToTotalProgress:NO];
        }
    } completionHandler:^(FSBlob *blob, NSError *error) {
        if (blob) {
            NSString *exportURL = [NSString stringWithFormat:@"%@/%@", path, fileNameWithExtension];
            NSDictionary *parameters = [self exportParametersWithStoreOptions:storeOptions blobURL:blob.url];

            [self exportURL:exportURL parameters:parameters];
        } else {
            [self messageDelegatesExportCompleteWithError:error];
        }

        if (delegateRespondsToUploadProgress) {
            [self.progressModalDelegate fsExportProgress:1.0 addToTotalProgress:NO];
        }
    }];
}

- (void)exportURL:(NSString *)exportURL parameters:(NSDictionary *)parameters {
    [Filestack exportURL:exportURL parameters:parameters completionHandler:^(FSBlob *blob, NSError *error) {
        if (blob) {
            [self messageDelegatesExportCompleteWithBlob:blob];
        } else {
            [self messageDelegatesExportCompleteWithError:error];
        }
    }];
}

- (NSDictionary *)exportParametersWithStoreOptions:(FSStoreOptions *)storeOptions blobURL:(NSString *)blobURL {
    NSMutableDictionary *parameters = [[storeOptions toQueryParameters] mutableCopy];
    parameters[@"url"] = blobURL;
    FSSession *session = [[FSSession alloc] initWithConfig:self.config];
    NSDictionary *sessionDictionary = [session toQueryParametersWithFormat:nil];
    [parameters addEntriesFromDictionary:sessionDictionary];

    return parameters;
}

- (NSData *)fileDataToExport {
    NSData *fileData;

    if (self.config.data) {
        fileData = self.config.data;
    } else if (self.config.localDataURL) {
        fileData = [[NSFileManager defaultManager] contentsAtPath:[self.config.localDataURL path]];
    }

    return fileData;
}

- (NSString *)fileNameWithName:(NSString *)name {
    NSString *fileName;
    NSCharacterSet *charSet = [NSCharacterSet alphanumericCharacterSet];
    NSString *safeName = [name stringByTrimmingCharactersInSet:[charSet invertedSet]];

    if (safeName && safeName.length > 0) {
        fileName = safeName;
    } else if (self.config.proposedFileName && !safeName) {
        fileName = self.config.proposedFileName;
    } else {
        fileName = [[NSUUID UUID] UUIDString]; // Just use a random string.
    }

    return fileName;
}

- (NSString *)addExtensionToFileName:(NSString *)name {
    NSString *fileNameWithExtension = [name stringByAppendingString:self.config.fileExtension];

    return fileNameWithExtension;
}

- (void)messageDelegatesExportCompleteWithBlob:(FSBlob *)blob {
    if ([self.progressModalDelegate respondsToSelector:@selector(fsExportComplete:)]) {
        [self.progressModalDelegate fsExportComplete:nil];
    }

    if ([self.exporterDelegate respondsToSelector:@selector(fsExportComplete:)]) {
        [self.exporterDelegate fsExportComplete:blob];
    }
}

- (void)messageDelegatesExportCompleteWithError:(NSError *)error {
    if ([self.progressModalDelegate respondsToSelector:@selector(fsExportError:)]) {
        [self.progressModalDelegate fsExportError:nil];
    }

    if ([self.exporterDelegate respondsToSelector:@selector(fsExportError:)]) {
        [self.exporterDelegate fsExportError:error];
    }

}
@end

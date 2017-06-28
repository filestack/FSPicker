//
//  FSConfig+Private.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 02/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import MobileCoreServices;
#import "FSConfig+Private.h"
#import "FSSource.h"

@interface FSConfig ()

@end

@implementation FSConfig (Private)

- (NSArray<FSSource *> *)fsLocalSourcesForSaving:(BOOL)forSaving {
    NSArray<FSSource *> *sourcesArray;

    if (self.sources.count == 0) {
        sourcesArray = [FSSource allLocalSources];
    } else {
        sourcesArray = [FSSource localSourcesWithIdentifiers:self.sources];
    }

    if (forSaving) {
        // We cannot write to every source.
        sourcesArray = [self setupAvailableSourcesForSaveMimeTypes:sourcesArray];
    } else {
        [self setupAvailableOpenMimeTypesForSources:sourcesArray];
    }

    return sourcesArray;
}

- (NSArray<FSSource *> *)fsRemoteSourcesForSaving:(BOOL)forSaving {
    NSArray<FSSource *> *sourcesArray;

    if (self.sources.count == 0) {
        sourcesArray = [FSSource allRemoteSources];
    } else {
        sourcesArray = [FSSource remoteSourcesWithIdentifiers:self.sources];
    }

    if (forSaving) {
        // We cannot write to every source.
        sourcesArray = [self setupAvailableSourcesForSaveMimeTypes:sourcesArray];
    } else {
        [self setupAvailableOpenMimeTypesForSources:sourcesArray];
    }

    return sourcesArray;
}

- (void)setupAvailableOpenMimeTypesForSources:(NSArray<FSSource *> *)sourcesArray {
    for (FSSource *source in sourcesArray) {
        [source configureMimeTypesForProvidedMimeTypes:self.mimeTypes];
    }
}

- (NSArray<FSSource *> *)setupAvailableSourcesForSaveMimeTypes:(NSArray<FSSource *> *)sourcesArray {
    NSMutableArray<FSSource *> *finalSourcesArray = [[NSMutableArray alloc] init];

    for (FSSource *source in sourcesArray) {
        if (source.isWriteable && [source allowsToSaveDataWithMimeType:self.dataMimeType]) {
            [finalSourcesArray addObject:source];
        }
    }

    return finalSourcesArray;
}

- (BOOL)showImages {
    return [self.mimeTypes containsObject:FSMimeTypeAll] ||
    [self.mimeTypes containsObject:FSMimeTypeImageAll] ||
    [self.mimeTypes containsObject:FSMimeTypeImageJPEG] ||
    [self.mimeTypes containsObject:FSMimeTypeImagePNG];

}

- (BOOL)showVideos {
    return [self.mimeTypes containsObject:FSMimeTypeAll] ||
    [self.mimeTypes containsObject:FSMimeTypeVideoAll] ||
    [self.mimeTypes containsObject:FSMimeTypeVideoQuickTime];

}

- (NSString *)fileExtension {
    if (self.dataExtension) {
        return [NSString stringWithFormat:@".%@", self.dataExtension];
    } else if (self.dataMimeType) {
        CFStringRef mimeType = (__bridge CFStringRef)self.dataMimeType;
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, NULL);
        CFStringRef extension = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
        CFRelease(uti);

        if (extension) {
            return [NSString stringWithFormat:@".%@", (__bridge_transfer NSString *)extension];
        }
    }

    return @"";
}

@end

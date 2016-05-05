//
//  FSConfig+Private.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 02/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSConfig+Private.h"
#import "FSSource.h"

@implementation FSConfig (Private)

- (NSArray<FSSource *> *)fsLocalSources {
    NSArray<FSSource *> *sourcesArray;

    if (self.sources.count == 0) {
        sourcesArray = [FSSource allLocalSources];
    } else {
        sourcesArray = [FSSource localSourcesWithIdentifiers:self.sources];
    }

    [self setupAvailableOpenMimeTypesForSources:sourcesArray];

    return sourcesArray;
}

- (NSArray<FSSource *> *)fsRemoteSources {
    NSArray<FSSource *> *sourcesArray;

    if (self.sources.count == 0) {
        sourcesArray = [FSSource allRemoteSources];
    } else {
        sourcesArray = [FSSource remoteSourcesWithIdentifiers:self.sources];
    }

    [self setupAvailableOpenMimeTypesForSources:sourcesArray];

    return sourcesArray;
}

- (void)setupAvailableOpenMimeTypesForSources:(NSArray<FSSource *> *)sourcesArray {
    for (FSSource *source in sourcesArray) {
        [source configureMimeTypesForProvidedMimeTypes:self.mimeTypes];
    }
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

@end

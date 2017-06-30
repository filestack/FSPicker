//
//  FSSource.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 02/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSource.h"
#import "FSConfig.h"

@interface FSSource ()

@property (nonatomic, copy, readwrite) NSArray *openMimeTypes;
@property (nonatomic, copy, readwrite) NSArray *saveMimeTypes;
@property (nonatomic, copy, readwrite) NSArray *mimeTypes;
@property (readwrite) BOOL itemsShouldPresentLabels;

@end

@implementation FSSource

- (NSString *)service {
    return [self.identifier lowercaseString];
}

- (BOOL)isWriteable {
    return self.saveMimeTypes.count != 0;
}

- (BOOL)allowsToSaveDataWithMimeType:(FSMimeType)mimeType {
    if ([self.saveMimeTypes containsObject:FSMimeTypeAll]) {
        return YES;
    }

    for (NSString *saveMimeType in self.saveMimeTypes) {
        // comparedMimeType:against: is returning nil if mimeTypes don't "match".
        if ([self comparedMimeType:mimeType against:saveMimeType]) {
            return YES;
        }
    }

    return NO;
}

- (void)configureMimeTypesForProvidedMimeTypes:(NSArray<NSString *> *)mimeTypes {
    if ([mimeTypes containsObject:FSMimeTypeAll] || !mimeTypes) {
        self.mimeTypes = self.openMimeTypes; // All mimeTypes or no mimeTypes set - take default.
    } else if (mimeTypes.count == 0) {
        self.mimeTypes = @[]; // Empty mimeTypes array provided.
    } else if ([self.openMimeTypes containsObject:FSMimeTypeAll]) {
        self.mimeTypes = mimeTypes; // If source accepts all mimeTypes - take what is provided.
    } else {
        BOOL containsImageAll = [self.openMimeTypes containsObject:FSMimeTypeImageAll];
        NSMutableArray *availableMimeTypes = [[NSMutableArray alloc] init];

        for (NSString *mimeType in mimeTypes) {
            if ([self.openMimeTypes containsObject:mimeType]) {
                [availableMimeTypes addObject:mimeType];
            } else if (containsImageAll && [mimeType containsString:@"image/"]) {
                [availableMimeTypes addObject:mimeType];
            } else {
                for (NSString *openMimeType in self.openMimeTypes) {
                    NSString *mimeTypeToAdd = [self comparedMimeType:openMimeType against:mimeType];

                    if (mimeTypeToAdd) {
                        [availableMimeTypes addObject:mimeTypeToAdd];
                    }
                }
            }
        }

        NSArray *uniqueAvailableMimeTypes = [[NSOrderedSet orderedSetWithArray:availableMimeTypes] array];
        self.mimeTypes = uniqueAvailableMimeTypes;
    }
}

- (NSString *)comparedMimeType:(NSString *)mimeType against:(NSString *)otherMimeType {
    NSArray *splittedMimeType = [mimeType componentsSeparatedByString:@"/"];
    NSArray *splittedOtherMimeType = [otherMimeType componentsSeparatedByString:@"/"];

    if ([splittedMimeType[0] isEqualToString:splittedOtherMimeType[0]]) { // Same "main type".
        if ([splittedOtherMimeType[1] isEqualToString:@"*"]) {
            return mimeType; // omts = [image/png, ...], mt = image/*, add image/png
        } else if ([splittedMimeType[1] isEqualToString:@"*"]) {
            return otherMimeType; // omts = [image/*, ...], mt = image/png, add image/png
        } else if ([splittedMimeType[1] isEqualToString:splittedOtherMimeType[1]]) {
            return otherMimeType; // omts = [image/png, ...], mt = image/png, add image/png
        }
    }

    return nil;
}

+ (NSArray<FSSource *> *)localSourcesWithIdentifiers:(NSArray<NSString *> *)identifiers {
    NSDictionary *localSources = [FSSource localSources];
    NSMutableArray *localSourcesArray = [[NSMutableArray alloc] init];

    for (NSString *identifier in identifiers) {
        if (localSources[identifier]) {
            FSSource *source = localSources[identifier];
            [localSourcesArray addObject:source];
        }
    }

    return localSourcesArray;
}

+ (NSArray<FSSource *> *)remoteSourcesWithIdentifiers:(NSArray<NSString *> *)identifiers {
    NSDictionary *remoteSources = [FSSource remoteSources];
    NSMutableArray *remoteSourcesArray = [[NSMutableArray alloc] init];

    for (NSString *identifier in identifiers) {
        if (remoteSources[identifier]) {
            FSSource *source = remoteSources[identifier];
            [remoteSourcesArray addObject:source];
        }
    }

    return remoteSourcesArray;
}

+ (NSDictionary<NSString *, FSSource *> *)allSources {
    NSMutableDictionary *allSources = [[NSMutableDictionary alloc] init];
    [allSources addEntriesFromDictionary:[FSSource localSources]];
    [allSources addEntriesFromDictionary:[FSSource remoteSources]];

    return allSources;
}

+ (NSArray<FSSource *> *)allLocalSources {
    return @[[FSSource sourceCamera],
             [FSSource sourceCameraRoll]];
}

+ (NSArray<FSSource *> *)allRemoteSources {
    return @[[FSSource sourceDropbox],
             [FSSource sourceFacebook],
             [FSSource sourceGmail],
             [FSSource sourceBox],
             [FSSource sourceGitHub],
             [FSSource sourceGoogleDrive],
             [FSSource sourceInstagram],
             [FSSource sourceFlickr],
             [FSSource sourceEvernote],
             [FSSource sourcePicasa],
             [FSSource sourceSkydrive],
             [FSSource sourceCloudDrive],
             [FSSource sourceImageSearch]];
}

+ (NSDictionary<NSString *, FSSource *> *)localSources {
    NSDictionary *localSourcesDictionary = @{FSSourceCamera: [FSSource sourceCamera],
                                             FSSourceCameraRoll: [FSSource sourceCameraRoll]};

    return localSourcesDictionary;
}

+ (NSDictionary<NSString *, FSSource *> *)remoteSources {
    NSDictionary *remoteSourcesDictionary = @{FSSourceDropbox: [FSSource sourceDropbox],
                                              FSSourceFacebook: [FSSource sourceFacebook],
                                              FSSourceGmail: [FSSource sourceGmail],
                                              FSSourceBox: [FSSource sourceBox],
                                              FSSourceGithub: [FSSource sourceGitHub],
                                              FSSourceGoogleDrive: [FSSource sourceGoogleDrive],
                                              FSSourceInstagram: [FSSource sourceInstagram],
                                              FSSourceFlickr: [FSSource sourceFlickr],
                                              FSSourceEvernote: [FSSource sourceEvernote],
                                              FSSourcePicasa: [FSSource sourcePicasa],
                                              FSSourceSkydrive: [FSSource sourceSkydrive],
                                              FSSourceCloudDrive: [FSSource sourceCloudDrive],
                                              FSSourceImageSearch: [FSSource sourceImageSearch]};

    return remoteSourcesDictionary;
}

#pragma mark - Available Sources

+ (FSSource *)sourceCamera {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceCamera;
    source.name = @"Camera";
    source.icon = @"icon-camera";
    source.rootPath = @"/Camera";
    source.openMimeTypes = @[@"video/quicktime", @"image/jpeg", @"image/png"];
    source.saveMimeTypes = @[];
    source.overwritePossible = NO;
    source.externalDomains = @[];
    source.itemsShouldPresentLabels = NO;

    return source;
}

+ (FSSource *)sourceCameraRoll {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceCameraRoll;
    source.name = @"Albums";
    source.icon = @"icon-albums";
    source.rootPath = @"/Albums";
    source.openMimeTypes = @[@"image/jpeg", @"image/png", @"video/quicktime"];
    source.saveMimeTypes = @[@"image/jpeg", @"image/png"];
    source.overwritePossible = NO;
    source.externalDomains = @[];
    source.itemsShouldPresentLabels = NO;

    return source;
}

+ (FSSource *)sourceDropbox {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceDropbox;
    source.name = @"Dropbox";
    source.icon = @"icon-dropbox";
    source.rootPath = @"/Dropbox";
    source.openMimeTypes = @[@"*/*"];
    source.saveMimeTypes = @[@"*/*"];
    source.overwritePossible = YES;
    source.externalDomains = @[@"https://www.dropbox.com"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = YES;

    return source;
}

+ (FSSource *)sourceFacebook {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceFacebook;
    source.name = @"Facebook";
    source.icon = @"icon-facebook";
    source.rootPath = @"/Facebook";
    source.openMimeTypes = @[@"image/jpeg"];
    source.saveMimeTypes = @[@"image/*"];
    source.overwritePossible = NO;
    source.externalDomains = @[@"https://www.facebook.com"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = YES;

    return source;
}

+ (FSSource *)sourceGmail {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceGmail;
    source.name = @"Gmail";
    source.icon = @"icon-gmail";
    source.rootPath = @"/Gmail";
    source.openMimeTypes = @[@"*/*"];
    source.saveMimeTypes = @[];
    source.overwritePossible = NO;
    source.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = YES;

    return source;
}

+ (FSSource *)sourceBox {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceBox;
    source.name = @"Box";
    source.icon = @"icon-box";
    source.rootPath = @"/Box";
    source.openMimeTypes = @[@"*/*"];
    source.saveMimeTypes = @[@"*/*"];
    source.overwritePossible = YES;
    source.externalDomains = @[@"https://www.box.com"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = YES;

    return source;
}

+ (FSSource *)sourceGitHub {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceGithub;
    source.name = @"Github";
    source.icon = @"icon-github";
    source.rootPath = @"/Github";
    source.openMimeTypes = @[@"*/*"];
    source.saveMimeTypes = @[];
    source.overwritePossible = NO;
    source.externalDomains = @[@"https://www.github.com"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = YES;

    return source;
}

+ (FSSource *)sourceGoogleDrive {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceGoogleDrive;
    source.name = @"Google Drive";
    source.icon = @"icon-googledrive";
    source.rootPath = @"/GoogleDrive";
    source.openMimeTypes = @[@"*/*"];
    source.saveMimeTypes = @[@"*/*"];
    source.overwritePossible = NO;
    source.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = YES;

    return source;
}

+ (FSSource *)sourceInstagram {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceInstagram;
    source.name = @"Instagram";
    source.icon = @"icon-instagram";
    source.rootPath = @"/Instagram";
    source.openMimeTypes = @[@"image/jpeg"];
    source.saveMimeTypes = @[];
    source.overwritePossible = YES;
    source.externalDomains = @[@"https://www.instagram.com",  @"https://instagram.com"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = NO;

    return source;
}

+ (FSSource *)sourceFlickr {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceFlickr;
    source.name = @"Flickr";
    source.icon = @"icon-flickr";
    source.rootPath = @"/Flickr";
    source.openMimeTypes = @[@"image/*"];
    source.saveMimeTypes = @[@"image/*"];
    source.overwritePossible = NO;
    source.externalDomains = @[@"https://*.flickr.com", @"http://*.flickr.com"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = NO;

    return source;
}

+ (FSSource *)sourceEvernote {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceEvernote;
    source.name = @"Evernote";
    source.icon = @"icon-evernote";
    source.rootPath = @"/Evernote";
    source.openMimeTypes = @[@"*/*"];
    source.saveMimeTypes = @[@"*/*"];
    source.overwritePossible = YES;
    source.externalDomains = @[@"https://www.evernote.com",  @"https://evernote.com"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = YES;

    return source;
}

+ (FSSource *)sourcePicasa {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourcePicasa;
    source.name = @"Google Photos";
    source.icon = @"icon_google_photos";
    source.rootPath = @"/Picasa";
    source.openMimeTypes = @[@"image/*"];
    source.saveMimeTypes = @[@"image/*"];
    source.overwritePossible = YES;
    source.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = NO;

    return source;
}

+ (FSSource *)sourceSkydrive {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceSkydrive;
    source.name = @"OneDrive";
    source.icon = @"icon-skydrive";
    source.rootPath = @"/OneDrive";
    source.openMimeTypes = @[@"*/*"];
    source.saveMimeTypes = @[@"*/*"];
    source.overwritePossible = YES;
    source.externalDomains = @[@"https://login.live.com",  @"https://skydrive.live.com"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = YES;

    return source;
}

+ (FSSource *)sourceCloudDrive {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceCloudDrive;
    source.name = @"Amazon Cloud Drive";
    source.icon = @"icon-clouddrive";
    source.rootPath = @"/Clouddrive";
    source.openMimeTypes = @[@"*/*"];
    source.saveMimeTypes = @[@"*/*"];
    source.overwritePossible = YES;
    source.externalDomains = @[@"https://www.amazon.com/clouddrive"];
    source.requiresAuth = YES;
    source.itemsShouldPresentLabels = YES;

    return source;
}

+ (FSSource *)sourceImageSearch {
    FSSource *source = [[FSSource alloc] init];

    source.identifier = FSSourceImageSearch;
    source.name = @"Web Images";
    source.icon = @"icon-search";
    source.rootPath = @"/Imagesearch";
    source.openMimeTypes = @[@"image/jpeg"];
    source.saveMimeTypes = @[];
    source.overwritePossible = NO;
    source.externalDomains = @[];
    source.requiresAuth = NO;
    source.itemsShouldPresentLabels = NO;

    return source;
}

@end

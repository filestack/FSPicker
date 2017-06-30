//
//  FSConfig.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 23/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSConfig.h"
#import <GTMAppAuth/GTMAppAuth.h>


// NSString *const FSSourceFilesystem = @"filesystem";
NSString *const FSSourceBox = @"box";
NSString *const FSSourceCameraRoll = @"cameraroll";
NSString *const FSSourceDropbox = @"dropbox";
NSString *const FSSourceFacebook = @"facebook";
NSString *const FSSourceGithub = @"github";
NSString *const FSSourceGmail = @"gmail";
NSString *const FSSourceImageSearch = @"imagesearch";
NSString *const FSSourceCamera = @"camera";
NSString *const FSSourceGoogleDrive = @"googledrive";
NSString *const FSSourceInstagram = @"instagram";
NSString *const FSSourceFlickr = @"flickr";
NSString *const FSSourcePicasa = @"picasa";
NSString *const FSSourceSkydrive = @"skydrive";
NSString *const FSSourceEvernote = @"evernote";
NSString *const FSSourceCloudDrive = @"clouddrive";

@implementation FSConfig

- (instancetype)initWithApiKey:(NSString *)apiKey storeOptions:(FSStoreOptions *)storeOptions {
    if ((self = [super init])) {
        _apiKey = apiKey;
        _storeOptions = storeOptions;
        _selectMultiple = YES;
        
        _service = [GTLRDriveService new];
        _gmailService = [GTLRGmailService new];
    }

    return self;
}

- (instancetype)initWithApiKey:(NSString *)apiKey {
    return [self initWithApiKey:apiKey storeOptions:nil];
}

- (instancetype)init {
    return [self initWithApiKey:nil storeOptions:nil];
}

- (NSArray<FSMimeType> *)mimeTypes {
    if (!_mimeTypes) {
        return @[FSMimeTypeAll];
    }

    return _mimeTypes;
}

@end

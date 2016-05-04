//
//  FSConfig.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 23/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <FilestackIOS/FSStoreOptions.h>
#import <FilestackIOS/FSSecurity.h>
//@import FilestackIOS.FSStoreOptions;
//@import FilestackIOS.FSSecurity;
@import UIKit;
#import "FSMimeTypes.h"

// extern NSString *const FSSourceFilesystem;
extern NSString *const FSSourceBox;
extern NSString *const FSSourceCameraRoll;
extern NSString *const FSSourceDropbox;
extern NSString *const FSSourceFacebook;
extern NSString *const FSSourceGithub;
extern NSString *const FSSourceGmail;
extern NSString *const FSSourceImageSearch;
extern NSString *const FSSourceCamera;
extern NSString *const FSSourceGoogleDrive;
extern NSString *const FSSourceInstagram;
extern NSString *const FSSourceFlickr;
extern NSString *const FSSourcePicasa;
extern NSString *const FSSourceSkydrive;
extern NSString *const FSSourceEvernote;
extern NSString *const FSSourceCloudDrive;

@interface FSConfig : NSObject

@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSArray<NSString *> *sources;
@property (nonatomic, copy) NSArray<FSMimeType> *mimeTypes;
@property (nonatomic, assign) NSInteger maxFiles;
@property (nonatomic, assign) BOOL selectMultiple;
@property (nonatomic, assign) BOOL shouldDownload;
@property (nonatomic, assign) BOOL shouldUpload;
@property (nonatomic, strong) FSStoreOptions *storeOptions;

- (instancetype)initWithApiKey:(NSString *)apiKey storeOptions:(FSStoreOptions *)storeOptions;
- (instancetype)initWithApiKey:(NSString *)apiKey;

@end

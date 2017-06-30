//
//  FSSource.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 02/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import Foundation;

@interface FSSource : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *rootPath;
@property (nonatomic, copy, readonly) NSArray *openMimeTypes;
@property (nonatomic, copy, readonly) NSArray *saveMimeTypes;
@property (nonatomic, copy, readonly) NSArray *mimeTypes;
@property (nonatomic, copy) NSArray *externalDomains;
@property (nonatomic, assign) BOOL overwritePossible;
@property (nonatomic, assign) BOOL requiresAuth;
@property (nonatomic, copy, readonly) NSString *service;
@property (nonatomic, assign, readonly) BOOL isWriteable;
@property (nonatomic, assign, readonly) BOOL itemsShouldPresentLabels;

+ (NSArray<FSSource *> *)localSourcesWithIdentifiers:(NSArray<NSString *> *)identifiers;
+ (NSArray<FSSource *> *)remoteSourcesWithIdentifiers:(NSArray<NSString *> *)identifiers;
+ (NSArray<FSSource *> *)allLocalSources;
+ (NSArray<FSSource *> *)allRemoteSources;

- (void)configureMimeTypesForProvidedMimeTypes:(NSArray<NSString *> *)mimeTypes;
- (BOOL)allowsToSaveDataWithMimeType:(NSString *)mimeType;

@end

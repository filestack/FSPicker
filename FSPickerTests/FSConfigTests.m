//
//  FSConfigTests.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 29/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSConfig.h"
#import "FSConfig+Private.h"
#import "FSSource.h"
@import FilestackIOS;

@interface FSConfigTests : XCTestCase

@end

@implementation FSConfigTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitNoStoreOptions {
    FSConfig *config = [[FSConfig alloc] initWithApiKey:@"apikey"];
    XCTAssertEqualObjects(@"apikey", config.apiKey);
    XCTAssertNil(config.storeOptions);
}

- (void)testInitStoreOptions {
    FSStoreOptions *storeOptions = [[FSStoreOptions alloc] init];
    FSConfig *config = [[FSConfig alloc] initWithApiKey:@"apikey" storeOptions:storeOptions];
    XCTAssertEqualObjects(@"apikey", config.apiKey);
    XCTAssertEqualObjects(storeOptions, config.storeOptions);
}

- (void)testMimeTypes {
    FSConfig *config = [[FSConfig alloc] initWithApiKey:@"apikey" storeOptions:nil];

    config.mimeTypes = @[];
    XCTAssertEqualObjects(@[], config.mimeTypes);

    config.mimeTypes = nil;
    XCTAssertEqualObjects(@[FSMimeTypeAll], config.mimeTypes);

    config.mimeTypes = @[FSMimeTypeAudioAll, @"*/*", FSMimeTypeImageAll, @"application/json"];
    NSArray *testArray = @[@"audio/*", FSMimeTypeAll, @"image/*", FSMimeTypeApplicationJSON];
    XCTAssertEqualObjects(testArray, config.mimeTypes);
}

- (void)testShowVideosOrImages {
    FSConfig *config = [[FSConfig alloc] initWithApiKey:@"apikey" storeOptions:nil];

    XCTAssertTrue([config showImages]);
    XCTAssertTrue([config showVideos]);

    config.mimeTypes = @[FSMimeTypeVideoQuickTime];
    XCTAssertFalse([config showImages]);
    XCTAssertTrue([config showVideos]);

    config.mimeTypes = @[FSMimeTypeImageJPEG];
    XCTAssertTrue([config showImages]);
    XCTAssertFalse([config showVideos]);

    config.mimeTypes = @[FSMimeTypeAll];
    XCTAssertTrue([config showImages]);
    XCTAssertTrue([config showVideos]);

    config.mimeTypes = @[FSMimeTypeApplicationJSON];
    XCTAssertFalse([config showImages]);
    XCTAssertFalse([config showVideos]);
}

- (void)testSources {
    FSConfig *config = [[FSConfig alloc] initWithApiKey:@"apikey" storeOptions:nil];
    NSArray *allLocalSources = [FSSource allLocalSources];
    NSArray *allRemoteSources = [FSSource allRemoteSources];

    config.sources = @[];
    [config.fsLocalSources enumerateObjectsUsingBlock:^(FSSource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XCTAssertEqualObjects(obj.identifier, ((FSSource *)allLocalSources[idx]).identifier);
    }];
    [config.fsRemoteSources enumerateObjectsUsingBlock:^(FSSource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XCTAssertEqualObjects(obj.identifier, ((FSSource *)allRemoteSources[idx]).identifier);
    }];

    config.sources = @[FSSourceDropbox];
    XCTAssertTrue(config.fsLocalSources.count == 0);
    XCTAssertTrue(config.fsRemoteSources.count == 1);
    XCTAssertEqualObjects(config.fsRemoteSources[0].identifier, FSSourceDropbox);

    config.sources = @[FSSourceDropbox, FSSourceCamera];
    XCTAssertTrue(config.fsLocalSources.count == 1);
    XCTAssertTrue(config.fsRemoteSources.count == 1);
    XCTAssertEqualObjects(config.fsRemoteSources[0].identifier, FSSourceDropbox);
    XCTAssertEqualObjects(config.fsLocalSources[0].identifier, FSSourceCamera);
}

@end

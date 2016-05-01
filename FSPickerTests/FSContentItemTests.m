//
//  FSContentItemTests.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 29/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSContentItem.h"

@interface FSContentItemTests : XCTestCase

@end

@implementation FSContentItemTests

- (void)setUp {
    [super setUp];

}

- (void)tearDown {

    [super tearDown];
}

- (void)testItemsFromResponse {
    NSDictionary *item = @{@"filename": @"name",
                           @"link_path": @"path",
                           @"mimetype": @"image/jpeg",
                           @"modified": @"1 hour ago",
                           @"size": @"500kB",
                           @"thumbnail": @"https://thumbanil.url",
                           @"is_dir": @"true",
                           @"count": @"10",
                           @"thumb_exists": @"true"};

    NSDictionary *contents = @{@"contents": @[item, item, item]};
    NSArray *items = [FSContentItem itemsFromResponseJSON:contents];

    XCTAssertTrue(items.count == 3);

    FSContentItem *contentItem = items.firstObject;

    XCTAssertEqualObjects(contentItem.fileName, item[@"filename"]);
    XCTAssertEqualObjects(contentItem.linkPath, item[@"link_path"]);
    XCTAssertEqualObjects(contentItem.mimeType, item[@"mimetype"]);
    XCTAssertEqualObjects(contentItem.modified, item[@"modified"]);
    XCTAssertEqualObjects(contentItem.size, item[@"size"]);
    XCTAssertEqualObjects(contentItem.thumbnailURL, item[@"thumbnail"]);
    XCTAssertEqual(contentItem.isDirectory, [item[@"is_dir"] boolValue]);
    XCTAssertTrue(contentItem.itemCount.integerValue == [item[@"count"] integerValue]);
    XCTAssertEqual(contentItem.thumbExists, [item[@"thumb_exists"] boolValue]);

}

- (void)testDetailsDescription {
    NSDictionary *item = @{@"filename": @"name",
                           @"link_path": @"path",
                           @"mimetype": @"image/jpeg",
                           @"modified": @"1 hour ago",
                           @"size": @"500kB",
                           @"thumbnail": @"https://thumbanil.url",
                           @"is_dir": @"true",
                           @"count": @"10",
                           @"thumb_exists": @"true"};

    NSMutableDictionary *mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];

    NSDictionary *contents = @{@"contents": @[mutableItem]};
    NSArray *items = [FSContentItem itemsFromResponseJSON:contents];

    FSContentItem *contentItem = items.firstObject;
    XCTAssertEqualObjects(contentItem.detailDescription, @"Folder | 10 files");

    mutableItem[@"is_dir"] = @"false";
    items = [FSContentItem itemsFromResponseJSON:contents];
    contentItem = items.firstObject;

    XCTAssertEqualObjects(contentItem.detailDescription, @"Modified 1 hour ago | 500kB");
}

@end

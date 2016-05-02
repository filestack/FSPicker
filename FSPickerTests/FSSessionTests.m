//
//  FSSessionTests.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 01/05/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSSession.h"
#import "FSConfig.h"
@import FilestackIOS;

@interface FSSessionTests : XCTestCase

@end

@implementation FSSessionTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testToQueryParams {
    NSString *apiKey = @"apikey";
    NSString *container = @"container";
    NSString *format = @"format";

    FSStoreOptions *storeOptions = [[FSStoreOptions alloc] init];

    storeOptions.access = FSAccessPublic;
    storeOptions.location = FSStoreLocationS3;
    storeOptions.container = container;

    FSConfig *config = [[FSConfig alloc] initWithApiKey:apiKey storeOptions:storeOptions];
    FSSession *session = [[FSSession alloc] initWithConfig:config mimeTypes:@[FSMimeTypeTextAll]];

    NSDictionary *sessionDict = [session toQueryParametersWithFormat:format];

    NSDictionary *jsonExample = @{@"apikey": apiKey,
                                  @"mimetypes": @[FSMimeTypeTextAll],
                                  @"storeAccess": storeOptions.access,
                                  @"storeLocation": storeOptions.location,
                                  @"storeContainer": storeOptions.container,
                                  @"version": @"v2"};

    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:jsonExample options:NSJSONWritingPrettyPrinted error:nil];
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(sessionDict[@"js_session"], JSONString);
    XCTAssertEqualObjects(sessionDict[@"format"], format);
}

@end

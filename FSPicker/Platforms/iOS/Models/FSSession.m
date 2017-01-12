//
//  FSSession.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 14/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSession.h"
#import "FSConfig.h"

@implementation FSSession


- (instancetype)initWithConfig:(FSConfig *)config mimeTypes:(NSArray<FSMimeType> *)mimeTypes {
    if ((self = [super init])) {
        _config = config;
        _mimeTypes = mimeTypes;
    }

    return self;
}

- (instancetype)initWithConfig:(FSConfig *)config {
    return [self initWithConfig:config mimeTypes:nil];
}

- (NSDictionary *)toQueryParametersWithFormat:(NSString *)format {
    NSDictionary *parameters = [self prepareQueryDictionary];
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    NSMutableDictionary *queryDictionary = [[NSMutableDictionary alloc] init];

    queryDictionary[@"js_session"] = JSONString;

    if (format) {
        queryDictionary[@"format"] = format;
    }

    if (self.nextPage) {
        queryDictionary[@"start"] = self.nextPage;
    }

    return queryDictionary;
}

- (NSDictionary *)prepareQueryDictionary {
    NSMutableDictionary *queryParameters = [[NSMutableDictionary alloc] init];
    FSStoreOptions *storeOptions = self.config.storeOptions;

    if (self.config.apiKey) {
        queryParameters[@"apikey"] = self.config.apiKey;
    }

    if (self.config.maxSize != 0) {
        queryParameters[@"maxSize"] = [NSString stringWithFormat:@"%lu", (unsigned long)self.config.maxSize];
    }

    if (self.mimeTypes) {
        queryParameters[@"mimetypes"] = self.mimeTypes;
    }

    if (storeOptions.access) {
        queryParameters[@"storeAccess"] = storeOptions.access;
    }

    if (storeOptions.location) {
        queryParameters[@"storeLocation"] = storeOptions.location;
    }

    if (storeOptions.path) {
        queryParameters[@"storePath"] = storeOptions.path;
    }

    if (storeOptions.container) {
        queryParameters[@"storeContainer"] = storeOptions.container;
    }

    if (storeOptions.security) {
        queryParameters[@"policy"] = storeOptions.security.policy;
        queryParameters[@"signature"] = storeOptions.security.signature;
    }

    queryParameters[@"version"] = @"v2";
    
    return queryParameters;
}

@end

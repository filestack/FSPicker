//
//  FSDownloader.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 12/01/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

#import "FSDownloader.h"
@import Filestack;

@implementation FSDownloader

- (void)download:(FSBlob *)blob security:(FSSecurity *)security completionHandler:(void (^)(NSString *fileURL, NSError *error))completionHandler {
    Filestack *filestack = [[Filestack alloc] initWithApiKey:@""];
    [filestack download:blob security:security completionHandler:^(NSData *data, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }

        NSString *uuidFileName = [NSString stringWithFormat:@"%@_%@", [[NSUUID UUID] UUIDString], blob.fileName];
        NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *fileURL = [tmpDirURL URLByAppendingPathComponent:uuidFileName];
        [data writeToFile:[fileURL path] atomically:YES];

        completionHandler([fileURL path], nil);
    }];
}

@end

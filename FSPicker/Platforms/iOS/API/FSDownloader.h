//
//  FSDownloader.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 12/01/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

@import Foundation;
@class FSBlob;
@class FSSecurity;

@interface FSDownloader : NSObject

- (void)download:(FSBlob *)blob security:(FSSecurity *)security completionHandler:(void (^)(NSString *fileURL, NSError *error))completionHandler;

@end

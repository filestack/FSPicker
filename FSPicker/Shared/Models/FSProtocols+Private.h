//
//  FSProtocols+Private.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 22/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@class FSBlob;

@protocol FSUploaderDelegate <NSObject>
@optional
- (void)fsUploadProgress:(float)progress addToTotalProgress:(BOOL)addToTotalProgress;
- (void)fsUploadComplete:(FSBlob *)blob;
- (void)fsUploadError:(NSError *)error;
- (void)fsUploadFinishedWithBlobs:(NSArray<FSBlob *> *)blobsArray;
@end

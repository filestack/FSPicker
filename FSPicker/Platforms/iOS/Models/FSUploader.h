//
//  FSUploader.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 14/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import Foundation;
#import "FSPickerController.h"
#import "FSProtocols+Private.h"
@class FSContentItem;
@class FSConfig;
@class FSSource;
@class FSSession;
@class PHAsset;

@interface FSUploader : NSObject

@property (nonatomic, weak) id <FSUploaderDelegate> uploadModalDelegate;
@property (nonatomic, weak) id <FSUploaderDelegate> pickerDelegate;

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source;
- (void)uploadCameraItem:(NSData *)itemData fileName:(NSString *)fileName;
- (void)uploadCloudItems:(NSArray<FSContentItem *> *)items;
- (void)uploadLocalItems:(NSArray<PHAsset *> *)items;

@end

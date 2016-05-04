//
//  FSProtocols.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 22/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@class FSBlob;
@class FSPickerController;

@protocol FSPickerDelegate <NSObject>
@optional
- (void)fsPickerDidCancel:(FSPickerController *)picker;
- (void)fsPicker:(FSPickerController *)picker pickingDidError:(NSError *)error;
- (void)fsPicker:(FSPickerController *)picker pickedMediaWithBlob:(FSBlob *)blob;
- (void)fsPicker:(FSPickerController *)picker didFinishedPickingMediaWithBlobs:(NSArray<FSBlob *> *)blobs;
@end
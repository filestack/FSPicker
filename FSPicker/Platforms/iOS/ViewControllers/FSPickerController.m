//
//  FSPickerController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 23/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSPickerController.h"
#import "FSSourceListViewController.h"

@implementation FSPickerController

- (instancetype)initWithConfig:(FSConfig *)config theme:(FSTheme *)theme {
    if ((self = [super initWithRootViewController:[[FSSourceListViewController alloc] initWithConfig:config]])) {
        _config = config;
        _theme = theme;

        if (_theme) {
            [_theme applyToController:self];
        } else {
            [FSTheme applyDefaultToController:self];
        }
    }

    return self;
}

- (instancetype)initWithConfig:(FSConfig *)config {
    return [self initWithConfig:config theme:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didCancel {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.fsDelegate respondsToSelector:@selector(fsPickerDidCancel:)]) {
            [self.fsDelegate fsPickerDidCancel:self];
        }
    });
}

- (void)fsUploadComplete:(FSBlob *)blob {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.fsDelegate respondsToSelector:@selector(fsPicker:pickedMediaWithBlob:)]) {
            [self.fsDelegate fsPicker:self pickedMediaWithBlob:blob];
        }
    });
}

- (void)fsUploadError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.fsDelegate respondsToSelector:@selector(fsPicker:pickingDidError:)]) {
            [self.fsDelegate fsPicker:self pickingDidError:error];
        }
    });
}

- (void)fsUploadFinishedWithBlobs:(NSArray<FSBlob *> *)blobsArray {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.fsDelegate respondsToSelector:@selector(fsPicker:didFinishedPickingMediaWithBlobs:)]) {
            [self.fsDelegate fsPicker:self didFinishedPickingMediaWithBlobs:blobsArray];
        }
    });
}

@end

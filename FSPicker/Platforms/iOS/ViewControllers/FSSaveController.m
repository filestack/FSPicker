//
//  FSSaveController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 13/05/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTheme.h"
#import "FSSaveController.h"
#import "FSSourceListViewController.h"
#import "FSProtocols+Private.h"

@interface FSSaveController () <FSExporterDelegate>

@end

@implementation FSSaveController

- (instancetype)initWithConfig:(FSConfig *)config theme:(FSTheme *)theme {
    if ((self = [super initWithRootViewController:[[FSSourceListViewController alloc] initWithConfig:config]])) {
        _theme = theme;
        _config = config;

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

- (instancetype)init {
    return [self initWithConfig:nil theme:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didCancel {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.fsDelegate respondsToSelector:@selector(fsSaveControllerDidCancel:)]) {
            [self.fsDelegate fsSaveControllerDidCancel:self];
        }
    });
}

- (void)fsExportComplete:(FSBlob *)blob {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.fsDelegate respondsToSelector:@selector(fsSaveController:didFinishSavingMediaWithBlob:)]) {
            [self.fsDelegate fsSaveController:self didFinishSavingMediaWithBlob:blob];
        }
    });
}

- (void)fsExportError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.fsDelegate respondsToSelector:@selector(fsSaveController:savingDidError:)]) {
            [self.fsDelegate fsSaveController:self savingDidError:error];
        }
    });
}

@end

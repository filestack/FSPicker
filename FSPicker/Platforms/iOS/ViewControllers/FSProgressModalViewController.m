//
//  FSProgressModalViewController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 14/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSProgressModalViewController.h"
#import "KAProgressLabel.h"

@interface FSProgressModalViewController ()

@property (nonatomic, strong) KAProgressLabel *progressLabel;

@end

@implementation FSProgressModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0.6];

    self.progressLabel = [[KAProgressLabel alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    self.progressLabel.trackWidth = 15;
    self.progressLabel.progressWidth = 15;
    self.progressLabel.fillColor = [UIColor clearColor];
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *constW = [NSLayoutConstraint constraintWithItem:self.progressLabel
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:150];

    NSLayoutConstraint *constH = [NSLayoutConstraint constraintWithItem:self.progressLabel
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:150];

    [self.progressLabel addConstraints:@[constW, constH]];

    NSLayoutConstraint *constX = [NSLayoutConstraint constraintWithItem:self.progressLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0];

    NSLayoutConstraint *constY = [NSLayoutConstraint constraintWithItem:self.progressLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0];

    [self.view addSubview:self.progressLabel];
    [self.view addConstraints:@[constX, constY]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fsUploadProgress:(float)progress addToTotalProgress:(BOOL)addToTotalProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLabel.labelVCBlock = ^(KAProgressLabel *label) {
            label.text = [NSString stringWithFormat:@"%.0f%%", (label.progress * 100)];
        };

        if (addToTotalProgress) {
            float totalProgress = (float)self.progressLabel.progress + progress;

            if ((int)totalProgress > 1) {
                totalProgress = 1.0;
            }

            [self.progressLabel setProgress:(double)totalProgress];
        } else {
            [self.progressLabel setProgress:(double)progress timing:TPPropertyAnimationTimingEaseOut duration:0.5 delay:0.0];
        }
    });
}

- (void)fsExportProgress:(float)progress addToTotalProgress:(BOOL)addToTotalProgress {
    [self fsUploadProgress:progress addToTotalProgress:addToTotalProgress];
}

- (void)fsUploadFinishedWithBlobs:(NSArray<FSBlob *> *)blobsArray completion:(void (^)())completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            if (completion) {
                completion();
            }
        }];
    });
}

- (void)fsUploadError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)fsExportComplete:(FSBlob *)blob {
    [self fsUploadFinishedWithBlobs:nil completion:nil];
}

- (void)fsExportError:(NSError *)error {
    [self fsUploadError:error];
}

@end

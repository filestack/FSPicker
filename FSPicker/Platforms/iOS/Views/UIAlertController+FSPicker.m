//
//  UIAlertController+FSPicker.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 16/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "UIAlertController+FSPicker.h"

@implementation UIAlertController (FSPicker)

+ (UIAlertController *)fsAlertWithError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alert addAction:confirmAction];

    return alert;
}

+ (UIAlertController *)fsAlertLogout {
    UIAlertController *logoutAlert = [UIAlertController alertControllerWithTitle:@"Logging out" message:@"\n" preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView *logoutIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [logoutAlert.view addSubview:logoutIndicator];
    logoutIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:logoutIndicator
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:logoutAlert.view
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:logoutIndicator
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:logoutAlert.view
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:50];
    [logoutAlert.view addConstraints:@[topConstraint, centerX]];
    [logoutIndicator startAnimating];

    return logoutAlert;
}

+ (UIAlertController *)fsAlertNoCamera {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Device has no camera available." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alert addAction:confirmAction];

    return alert;
}

@end

//
//  FSActivityIndicatorView.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 15/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSActivityIndicatorView.h"

@implementation FSActivityIndicatorView

- (instancetype)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style inViewController:(UIViewController *)viewController {
    if ((self = [super initWithActivityIndicatorStyle:style])) {
        self.center = viewController.view.center;
        self.hidesWhenStopped = YES;
        [viewController.view addSubview:self];
    }

    return self;
}

@end

//
//  UINavigationController+Progress.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 11/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;
#import "FSProgressView.h"

@interface UINavigationController (Progress)

@property (nonatomic, strong, readonly) FSProgressView *fsProgressView;

- (void)fsResetProgressView;

@end

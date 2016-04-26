//
//  FSProgressView.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 11/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;

@interface FSProgressView : UIProgressView

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController frame:(CGRect)frame;
- (void)animateFadeOutAndHide;
- (void)setupConstraints;

@end

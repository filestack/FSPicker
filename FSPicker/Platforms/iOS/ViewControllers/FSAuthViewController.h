//
//  FSAuthViewController.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 11/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;
@class FSSource;
@class FSConfig;

@protocol FSAuthViewControllerDelegate <NSObject>

- (void)didAuthenticateWithSource;
- (void)didFailToAuthenticateWithSource;

@end

@interface FSAuthViewController : UIViewController

@property (nonatomic, weak, nullable) id<FSAuthViewControllerDelegate> delegate;

- (instancetype _Nullable)initWithConfig:(FSConfig * _Nonnull)config source:(FSSource * _Nonnull)source;

@end

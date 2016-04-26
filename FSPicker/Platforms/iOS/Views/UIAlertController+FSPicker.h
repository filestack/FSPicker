//
//  FSAlertController+FSPicker.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 16/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;

@interface UIAlertController (FSPicker)

+ (UIAlertController *)fsAlertWithError:(NSError *)error;
+ (UIAlertController *)fsAlertNoCamera;
+ (UIAlertController *)fsAlertLogout;

@end

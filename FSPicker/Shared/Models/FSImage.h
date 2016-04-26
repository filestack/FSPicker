//
//  FSImage.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 16/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface FSImage : NSObject

+ (UIImage *)iconNamed:(NSString *)iconName;
+ (UIImage *)cellSelectedOverlay;

@end

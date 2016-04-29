//
//  FSListTableViewCell.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 17/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;

@interface FSListTableViewCell : UITableViewCell

@property (nonatomic, assign) NSUInteger taskHash;
@property (nonatomic, weak) NSURLSessionDataTask *imageTask;
@property (nonatomic, copy) UIColor *selectedBackgroundColor UI_APPEARANCE_SELECTOR;

@end

//
//  FSConfig+Private.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 02/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSConfig.h"
@class FSSource;

@interface FSConfig (Private)

- (NSArray<FSSource *> *)fsLocalSources;
- (NSArray<FSSource *> *)fsRemoteSources;
- (BOOL)showImages;
- (BOOL)showVideos;

@end

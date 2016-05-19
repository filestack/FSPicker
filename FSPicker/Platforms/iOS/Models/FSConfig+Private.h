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

- (NSArray<FSSource *> *)fsLocalSourcesForSaving:(BOOL)forSaving;
- (NSArray<FSSource *> *)fsRemoteSourcesForSaving:(BOOL)forSaving;
- (BOOL)showImages;
- (BOOL)showVideos;
- (NSString *)fileExtension;

@end

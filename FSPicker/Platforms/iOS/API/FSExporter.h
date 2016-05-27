//
//  FSExporter.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 19/05/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSProtocols+Private.h"
@class FSConfig;

@interface FSExporter : NSObject

@property (nonatomic, weak) id <FSExporterDelegate> exporterDelegate;
@property (nonatomic, weak) id <FSExporterDelegate> progressModalDelegate;

- (instancetype)initWithConfig:(FSConfig *)config;
- (void)saveDataToCameraRoll;
- (void)saveDataNamed:(NSString *)name toPath:(NSString *)path;

@end

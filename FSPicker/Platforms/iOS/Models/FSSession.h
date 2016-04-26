//
//  FSSession.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 14/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import Foundation;
#import "FSMimeTypes.h"
@class FSConfig;

@interface FSSession : NSObject

@property (nonatomic, strong) FSConfig *config;
@property (nonatomic, copy) NSArray<FSMimeType> *mimeTypes;
@property (nonatomic, copy) NSString *nextPage;

- (instancetype)initWithConfig:(FSConfig *)config mimeTypes:(NSArray<FSMimeType> *)mimeTypes;
- (instancetype)initWithConfig:(FSConfig *)config;
- (NSDictionary *)toQueryParametersWithFormat:(NSString *)format;

@end

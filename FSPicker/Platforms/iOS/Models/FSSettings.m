//
//  FSSettings.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 11/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSettings.h"

@implementation FSSettings

+ (NSArray *)allowedUrlPrefixList {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"fsAllowedUrlPrefix" withExtension:@"plist"];

    return [NSArray arrayWithContentsOfURL:url];
}

@end

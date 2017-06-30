//
//  NSURLResponse+ImageMimeType.m
//  FSPicker
//
//  Created by Ruben Nine on 30/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

#import "NSURLResponse+ImageMimeType.h"
@import MobileCoreServices;

@implementation NSURLResponse (ImageMimeType)

-(BOOL)hasImageMIMEType {

    CFStringRef responseUTI = (UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
                                                                     (__bridge CFStringRef _Nonnull)(self.MIMEType),
                                                                     NULL));

    Boolean isImage = UTTypeConformsTo(responseUTI, kUTTypeImage);

    return isImage ? YES : NO;
}

@end

//
//  FSContentItem.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 15/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import Foundation;
#import "GTLRDrive.h"
#import "GTLRGmail.h"


@interface FSContentItem : NSObject

@property (nonatomic, copy, readonly) NSString *fileName;
@property (nonatomic, copy, readonly) NSString *linkPath;
@property (nonatomic, copy, readonly) NSString *mimeType;
@property (nonatomic, copy, readonly) NSString *modified;
@property (nonatomic, copy, readonly) NSString *size;
@property (nonatomic, copy, readonly) NSString *thumbnailURL;
@property (nonatomic, copy, readonly) NSString *detailDescription;
@property (nonatomic, assign, readonly) NSNumber *itemCount;
@property (nonatomic, assign, readonly) BOOL isDirectory;
@property (nonatomic, assign, readonly) BOOL thumbExists;

@property (nonatomic, copy) NSString *fileExtension;
@property (nonatomic, copy) NSString *fullFileExtension;

//! Gmail
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *attachmentId;

+ (NSArray<FSContentItem *> *)itemsFromResponseJSON:(NSDictionary *)json;
+ (NSArray<FSContentItem *> *)itemsFromGTLRDriveFileList:(GTLRDrive_FileList *)fileList;
+ (NSArray<FSContentItem *> *)itemsFromGTLRGmailMessages:(NSArray *)messages;
+ (NSArray<FSContentItem *> *)itemsFromGTLRGmailMessage:(GTLRGmail_Message *)message;
@end

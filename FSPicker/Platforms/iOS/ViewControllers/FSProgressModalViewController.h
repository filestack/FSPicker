//
//  FSProgressModalViewController.h
//  FSPicker
//
//  Created by Łukasz Cichecki on 14/04/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import UIKit;
#import "FSUploader.h"
#import "FSExporter.h"

@interface FSProgressModalViewController : UIViewController <FSUploaderDelegate, FSExporterDelegate>

@end

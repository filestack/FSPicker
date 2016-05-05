//
//  FSSourceListViewController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 02/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSourceListViewController.h"
#import "FSConfig.h"
#import "FSConfig+Private.h"
#import "FSSource.h"
#import "FSSourceTableViewCell.h"
#import "FSAlbumsViewController.h"
#import "FSSourceViewController.h"
#import "FSSearchViewController.h"
#import "UIAlertController+FSPicker.h"
#import "FSUploadModalViewController.h"
#import "FSPickerController+Private.h"

@interface FSSourceListViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) FSConfig *config;
@property (nonatomic, copy) NSMutableArray<NSArray<FSSource *> *> *dataSources;
@property (nonatomic, copy) NSMutableArray<NSString *> *dataSourcesSectionTitles;

@end

@implementation FSSourceListViewController

- (instancetype)initWithConfig:(FSConfig *)config {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        _config = config;
        _dataSources = [[NSMutableArray alloc] init];
        _dataSourcesSectionTitles = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTitleAndNavigation];
    [self setupDataSources];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View setup

- (void)setupDataSources {
    if (!self.config) {
        return;
    }

    NSArray *localSources = [self.config fsLocalSources];
    NSArray *remoteSources = [self.config fsRemoteSources];

    if (self.config.sources.count != 0) {
        if (localSources.count != 0) {
            [self addDataSource:localSources withSectionTitle:@"Local"];
        }

        if (remoteSources.count != 0) {
            [self addDataSource:remoteSources withSectionTitle:@"Cloud"];
        }
    } else {
        [self addDataSource:localSources withSectionTitle:@"Local"];
        [self addDataSource:remoteSources withSectionTitle:@"Cloud"];
    }
}

- (void)addDataSource:(NSArray<FSSource *> *)dataSource withSectionTitle:(NSString *)sectionTitle {
    [self.dataSources addObject:dataSource];
    [self.dataSourcesSectionTitles addObject:sectionTitle];
}

- (void)setupTitleAndNavigation {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(dismissController)];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];

    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.backBarButtonItem = backButton;

    if (!self.title) {
        self.title = @"Filestack";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources[section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.dataSourcesSectionTitles.count <= 1) {
        return nil;
    }

    return self.dataSourcesSectionTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSSourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fsCell"];
    
    if (!cell) {
        cell = [[FSSourceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fsCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    FSSource *source = [self sourceAtIndexPath:indexPath];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *image = [[UIImage imageNamed:source.icon
                                 inBundle:bundle
            compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    cell.imageView.image = image;
    cell.textLabel.text = source.name;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSSource *source = [self sourceAtIndexPath:indexPath];

    if ([source.identifier isEqualToString:FSSourceCameraRoll]) {
        FSAlbumsViewController *destinationController = [[FSAlbumsViewController alloc] initWithConfig:self.config source:source];
        [self.navigationController pushViewController:destinationController animated:YES];
    } else if ([source.identifier isEqualToString:FSSourceImageSearch]) {
        FSSearchViewController *searchController = [[FSSearchViewController alloc] initWithConfig:self.config source:source];
        [self.navigationController pushViewController:searchController animated:YES];
    } else if ([source.identifier isEqualToString:FSSourceCamera]) {
        [self setupAndPresentImagePickerControllerForCellAtIndexPath:indexPath];
    } else {
        FSSourceViewController *destinationController = [[FSSourceViewController alloc] initWithConfig:self.config source:source];
        [self.navigationController pushViewController:destinationController animated:YES];
    }
}

- (FSSource *)sourceAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSources[indexPath.section][indexPath.row];
}

#pragma mark - UIImagePickerController

- (void)setupAndPresentImagePickerControllerForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert = [UIAlertController fsAlertNoCamera];
        [self presentViewController:alert animated:YES completion:^{
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        return;
    }

    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];

    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.allowsEditing = NO;

    if ([self.config showImages]) {
        [mediaTypes addObject:@"public.image"];
    }

    if ([self.config showVideos]) {
        [mediaTypes addObject:@"public.movie"];
    }

    pickerController.mediaTypes = mediaTypes;
    pickerController.delegate = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:pickerController animated:YES completion:nil];
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        FSUploadModalViewController *uploadModal = [[FSUploadModalViewController alloc] init];
        uploadModal.modalPresentationStyle = UIModalPresentationOverCurrentContext;

        FSUploader *uploader = [[FSUploader alloc] initWithConfig:self.config source:nil];
        uploader.uploadModalDelegate = uploadModal;
        uploader.pickerDelegate = (FSPickerController *)self.navigationController;

        [self presentViewController:uploadModal animated:YES completion:nil];

        if (info[UIImagePickerControllerOriginalImage]) {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            NSData *imageData = UIImagePNGRepresentation(image);
            NSString *fileName = [NSString stringWithFormat:@"Image_%@.jpg", [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
            NSCharacterSet *dateFormat = [NSCharacterSet characterSetWithCharactersInString:@"/: "];
            fileName = [[fileName componentsSeparatedByCharactersInSet:dateFormat] componentsJoinedByString:@"-"];

            [uploader uploadCameraItem:imageData fileName:fileName];
        } else if (info[UIImagePickerControllerMediaURL]) {
            NSURL *fileURL = info[UIImagePickerControllerMediaURL];
            NSString *fileName = fileURL.lastPathComponent;
            NSData *videoData = [NSData dataWithContentsOfURL:fileURL];

            [uploader uploadCameraItem:videoData fileName:fileName];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end

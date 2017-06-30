//
//  FSSaveSourceViewController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 20/05/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSaveSourceViewController.h"
#import "FSProgressModalViewController.h"
#import "FSSaveController+Private.h"
#import "FSSaveController.h"
#import "FSBarButtonItem.h"
#import "FSExporter.h"
#import "FSConfig.h"
#import "FSSource.h"

@interface FSSourceViewController ()

@property (nonatomic, strong, readwrite) FSSource *source;

@end

@interface FSSaveSourceViewController () <UITextFieldDelegate>

@property (nonatomic, strong) FSConfig *config;
@property (nonatomic, assign) BOOL toolbarColorsSet;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign, readwrite) BOOL inListView;
@property (nonatomic, assign) CGFloat currentKeyboardHeight;

@end

@implementation FSSaveSourceViewController

@dynamic inListView;

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source {
    if ((self = [super initWithConfig:config source:source])) {
        self.config = config;
        self.source = source;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.config.proposedFileName) {
        self.textField.text = self.config.proposedFileName;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardChangedSize:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];

    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification
                                                  object:nil];
}

- (void)setupToolbar {
    if (!self.toolbarColorsSet) {
        self.toolbarColorsSet = YES;
        self.navigationController.toolbar.barTintColor = [FSBarButtonItem appearance].backgroundColor;
        self.navigationController.toolbar.tintColor = [FSBarButtonItem appearance].normalTextColor;
    }

    [self setToolbarItems:@[[self spaceButtonItem], [self textFieldItem], [self spaceButtonItem], [self saveButtonItem], [self spaceButtonItem]] animated:NO];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (UIBarButtonItem *)saveButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveContent)];
}

- (UIBarButtonItem *)spaceButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)textFieldItem {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 25)];

    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, 25)];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.tintColor = [UIColor darkTextColor];
    self.textField.placeholder = @"filename";
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.layer.cornerRadius = 5.0f;
    self.textField.layer.borderWidth = 1.0f;
    self.textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textField.clipsToBounds = YES;
    self.textField.delegate = self;

    UIBarButtonItem *filename = [[UIBarButtonItem alloc] initWithCustomView:self.textField];

    return filename;
}

- (void)loadDirectory:(NSString *)directoryPath {
    FSSaveSourceViewController *directoryController = [[FSSaveSourceViewController alloc] initWithConfig:self.config source:self.source];
    directoryController.loadPath = directoryPath;
    directoryController.inListView = self.inListView;
    [self.navigationController pushViewController:directoryController animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGSize keyboardSize = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    [UIView beginAnimations:nil context:nil];

    [UIView setAnimationDuration:0.3];

    CGRect frame = self.navigationController.toolbar.frame;
    frame.origin.y -= keyboardSize.height;
    self.navigationController.toolbar.frame = frame;

    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGSize keyboardSize = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    [UIView beginAnimations:nil context:nil];

    [UIView setAnimationDuration:0.3];

    CGRect frame = self.navigationController.toolbar.frame;
    frame.origin.y += keyboardSize.height;
    self.navigationController.toolbar.frame = frame;

    [UIView commitAnimations];
}

- (void)keyboardChangedSize:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGSize keyboardSize = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    if (keyboardSize.height != self.currentKeyboardHeight) {
        if ((int)self.currentKeyboardHeight != 0) {
            CGRect frame = self.navigationController.toolbar.frame;
            frame.origin.y += keyboardSize.height;
            [UIView animateWithDuration:0.3 animations:^{
                self.navigationController.toolbar.frame = frame;
            }];
        }
        self.currentKeyboardHeight = keyboardSize.height;

    }
}

- (void)saveContent {
    FSProgressModalViewController *progressModal = [[FSProgressModalViewController alloc] init];
    progressModal.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    NSString *path = self.loadPath ?: self.source.rootPath;
    NSString *name = self.textField.text;

    FSExporter *exporter = [[FSExporter alloc] initWithConfig:self.config];
    exporter.exporterDelegate = (FSSaveController *)self.navigationController;
    exporter.progressModalDelegate = progressModal;
    [exporter saveDataNamed:name toPath:path];

    [self presentViewController:progressModal animated:YES completion:nil];
}

- (void)uploadSelectedContents {
    // NO-OP
}

- (void)updateToolbar {
    // NO-OP
}

- (void)selectContentItem:(FSContentItem *)item atIndexPath:(NSIndexPath *)indexPath forTableView:(BOOL)tableView collectionView:(BOOL)collectionView {
    // NO-OP
}

- (void)deselectContentItem:(FSContentItem *)item atIndexPath:(NSIndexPath *)indexPath forTableView:(BOOL)tableView collectionView:(BOOL)collectionView {
    // NO-OP
}

@end

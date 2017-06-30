//
//  FSSourceViewController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 08/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSImage.h"
#import "FSConfig.h"
#import "FSSource.h"
#import "FSSession.h"
#import "FSUploader.h"
#import "FSContentItem.h"
#import "FSBarButtonItem.h"
#import "FSAuthViewController.h"
#import "FSSourceViewController.h"
#import "FSActivityIndicatorView.h"
#import "FSSaveController+Private.h"
#import "UIAlertController+FSPicker.h"
#import "FSPickerController+Private.h"
#import "FSSourceTableViewController.h"
#import "FSProgressModalViewController.h"
#import "FSSourceCollectionViewController.h"
#import <Filestack/Filestack+FSPicker.h>

#import "GTLRDrive.h"
#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>


@interface FSSourceViewController () <FSAuthViewControllerDelegate>

@property (nonatomic, assign) BOOL toolbarColorsSet;
@property (nonatomic, assign) BOOL initialContentLoad;
@property (nonatomic, assign, readwrite) BOOL lastPage;
@property (nonatomic, assign, readwrite) BOOL inListView;
@property (nonatomic, strong, readonly) FSConfig *config;
@property (readwrite) FSSource *source;
@property (nonatomic, strong, readwrite) NSString *nextPage;
@property (nonatomic, strong, readonly) UIBarButtonItem *uploadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray<FSContentItem *> *selectedContent;
@property (nonatomic, strong) FSSourceTableViewController *tableViewController;
@property (nonatomic, strong) FSSourceCollectionViewController *collectionViewController;

@property (nonatomic, strong) GTLRServiceTicket* fileListTicket;

@end

@implementation FSSourceViewController

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source {
    if ((self = [super init])) {
        _config = config;
        _source = source;
        _inListView = YES;
        _initialContentLoad = YES;
        _selectedContent = [[NSMutableArray alloc] init];
        _tableViewController = [[FSSourceTableViewController alloc] initWithStyle:UITableViewStylePlain];
        _collectionViewController = [[FSSourceCollectionViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionViewController.selectMultiple = config.selectMultiple;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableViewController.sourceController = self;
    self.collectionViewController.sourceController = self;
    
    self.title = self.source.name;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (self.inListView) {
        [self addTableViewController];
        self.tableViewController.alreadyDisplayed = YES;
    } else {
        [self addCollectionViewController];
        self.collectionViewController.alreadyDisplayed = YES;
    }
    
    [self setupListGridSwitchButton];
    [self setupActivityIndicator];
    [self setupToolbar];
    [self disableUI];
    
    //! Load auth
    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive]) {
        // Deserialize from Keychain
        GTMAppAuthFetcherAuthorization* authorization = [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:@"kGTMAppAuthExampleAuthorizerKey-Drive"];
        if (authorization.authState.isAuthorized == YES){
            self.config.service.authorizer = authorization;
        }
    }
    
    if ([self.source.identifier isEqualToString:FSSourcePicasa]) {
        // Deserialize from Keychain
        GTMAppAuthFetcherAuthorization* authorization = [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:@"kGTMAppAuthExampleAuthorizerKey-Picasa"];
        if (authorization.authState.isAuthorized == YES){
            self.config.service.authorizer = authorization;
        }
    }
    
    if ([self.source.identifier isEqualToString:FSSourceGmail]) {
        // Deserialize from Keychain
        GTMAppAuthFetcherAuthorization* authorization = [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:@"kGTMAppAuthExampleAuthorizerKey-Gmail"];
        if (authorization.authState.isAuthorized == YES){
            self.config.gmailService.authorizer = authorization;
        }
    }
    
    [self loadSourceContent:nil isNextPage:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

#pragma mark - Upload button

- (void)setupToolbar {
    [self setToolbarItems:@[[self spaceButtonItem], [self uploadButtonItem], [self spaceButtonItem]] animated:NO];
}

- (UIBarButtonItem *)spaceButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)uploadButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(uploadSelectedContents)];
}

- (void)updateToolbar {
    if (!self.toolbarColorsSet) {
        self.toolbarColorsSet = YES;
        self.navigationController.toolbar.barTintColor = [FSBarButtonItem appearance].backgroundColor;
        self.navigationController.toolbar.tintColor = [FSBarButtonItem appearance].normalTextColor;
    }
    
    if (self.selectedContent.count > 0) {
        [self updateListAndGridInsetsForToolbarHidden:NO];
        [self.navigationController setToolbarHidden:NO animated:YES];
        [self updateToolbarButtonTitle];
    } else {
        [self updateListAndGridInsetsForToolbarHidden:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

- (void)updateListAndGridInsetsForToolbarHidden:(BOOL)hidden {
    CGFloat toolbarHeight = self.navigationController.toolbar.frame.size.height;
    BOOL currentlyHidden = self.navigationController.toolbar.isHidden;
    [self.tableViewController updateTableInsetsForToolbarHidden:hidden currentlyHidden:currentlyHidden toolbarHeight:toolbarHeight];
    [self.collectionViewController updateCollectionInsetsForToolbarHidden:hidden currentlyHidden:currentlyHidden toolbarHeight:toolbarHeight];
}

- (void)updateToolbarButtonTitle {
    NSString *title;
    
    if ((long)self.selectedContent.count > self.config.maxFiles && self.config.maxFiles != 0) {
        title = [NSString stringWithFormat:@"Maximum %lu file%@", (long)self.config.maxFiles, self.config.maxFiles > 1 ? @"s" : @""];
        self.uploadButton.enabled = NO;
    } else {
        title = [NSString stringWithFormat:@"Upload %lu file%@", (unsigned long)self.selectedContent.count, self.selectedContent.count > 1 ? @"s" : @""];
        self.uploadButton.enabled = YES;
    }
    
    [self.uploadButton setTitle:title];
}

- (UIBarButtonItem *)uploadButton {
    return self.toolbarItems[1];
}

- (void)uploadSelectedContents {
    FSProgressModalViewController *uploadModal = [[FSProgressModalViewController alloc] init];
    uploadModal.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    FSUploader *uploader = [[FSUploader alloc] initWithConfig:self.config source:self.source];
    uploader.uploadModalDelegate = uploadModal;
    uploader.pickerDelegate = (FSPickerController *)self.navigationController;
    
    [self presentViewController:uploadModal animated:YES completion:nil];
    [uploader uploadCloudItems:self.selectedContent];
    [self clearSelectedContent];
    [self.collectionViewController clearAllCollectionItems]; // Clean this :O
}

#pragma mark - Setup view

- (void)setupActivityIndicator {
    self.activityIndicator = [[FSActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite inViewController:self];
}

- (void)addTableViewController {
    [self fsAddChildViewController:self.tableViewController];
}

- (void)addCollectionViewController {
    [self fsAddChildViewController:self.collectionViewController];
}

- (void)setupListGridSwitchButton {
    UIImage *listGridImage = [self imageForViewType];
    UIImage *logoutImage = [FSImage iconNamed:@"icon-logout"];
    
    UIBarButtonItem *listGridButton = [[UIBarButtonItem alloc] initWithImage:listGridImage
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(listGridSwitch:)];
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithImage:logoutImage
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(logout)];
    
    self.navigationItem.rightBarButtonItems = @[logoutButton, listGridButton];
}

- (UIImage *)imageForViewType {
    NSString *imageName;
    
    if (self.inListView) {
        imageName = @"icon-grid";
    } else {
        imageName = @"icon-list";
    }
    
    return [FSImage iconNamed:imageName];
}

#pragma mark - Data

- (void)loadSourceContent:(void (^)(BOOL success))completion isNextPage:(BOOL)isNextPage {
    
    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive]
        || [self.source.identifier isEqualToString:FSSourceGmail]
        || [self.source.identifier isEqualToString:FSSourcePicasa]) {
        [self loadGoogleServiceSourceContent:completion isNextPage:isNextPage];
        return;
    }
    
    if (self.initialContentLoad) {
        self.initialContentLoad = NO;
        [self.activityIndicator startAnimating];
    }
    
    FSSession *session = [[FSSession alloc] initWithConfig:self.config mimeTypes:self.source.mimeTypes];
    
    if (self.nextPage) {
        session.nextPage = self.nextPage;
    }
    
    NSDictionary *parameters = [session toQueryParametersWithFormat:@"info"];
    NSString *contentPath = self.loadPath ? self.loadPath : self.source.rootPath;
    
    [Filestack getContentForPath:contentPath parameters:parameters completionHandler:^(NSDictionary *responseJSON, NSError *error) {
        [self.activityIndicator stopAnimating];
        
        id nextPage = responseJSON[@"next"];
        
        if (nextPage && nextPage != [NSNull null]) {
            self.nextPage = [nextPage respondsToSelector:@selector(stringValue)] ? [nextPage stringValue] : nextPage;
            self.lastPage = NO;
        } else {
            self.lastPage = self.nextPage != nil;
            self.nextPage = nil;
        }
        
        if (error) {
            self.nextPage = nil;
            self.lastPage = NO;
            [self enableRefreshControls];
            [self showAlertWithError:error];
        } else if (responseJSON[@"auth"]) {
            [self authenticateWithCurrentSource];
        } else {
            [self enableUI];
            NSArray *items = [FSContentItem itemsFromResponseJSON:responseJSON];
            [self.tableViewController contentDataReceived:items isNextPageData:isNextPage];
            [self.collectionViewController contentDataReceived:items isNextPageData:isNextPage];
        }
        
        if (completion) {
            completion(error == nil);
        }
    }];
}

- (void)loadGoogleServiceSourceContent:(void (^)(BOOL success))completion isNextPage:(BOOL)isNextPage {
    
    if (self.initialContentLoad) {
        self.initialContentLoad = NO;
        [self.activityIndicator startAnimating];
    }
    
    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive]) {
        
        GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
        query.fields = @"kind,nextPageToken,files";
        
        query.orderBy = @"folder,name";
        
        if (self.loadPath) {
            query.q = [NSString stringWithFormat:@"'%@' IN parents", self.loadPath];
        }else{
            query.q = [NSString stringWithFormat:@"'%@' IN parents", @"root"];
        }
        
        
        if (self.nextPage) {
            query.pageToken = self.nextPage;
        }
        
        self.fileListTicket = [self.config.service executeQuery:query
                                              completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                                  GTLRDrive_FileList *fileList,
                                                                  NSError *callbackError) {
                                                  [self.activityIndicator stopAnimating];
                                                  
                                                  if (callbackError.code == 403 || callbackError.code == 400) {
                                                      [self authenticateWithCurrentSource];
                                                      return;
                                                  }
                                                  
                                                  self.nextPage = fileList.nextPageToken;
                                                  
                                                  if (self.nextPage) {
                                                      self.lastPage = NO;
                                                  } else {
                                                      self.lastPage = YES;
                                                  }
                                                  
                                                  [self enableUI];
                                                  NSArray *items = [FSContentItem itemsFromGTLRDriveFileList:fileList];
                                                  [self.tableViewController contentDataReceived:items isNextPageData:isNextPage];
                                                  [self.collectionViewController contentDataReceived:items isNextPageData:isNextPage];
                                                  
                                                  self.fileListTicket = nil;
                                                  
                                                  if (completion) {
                                                      completion(callbackError == nil);
                                                  }
                                                  
                                              }];
        
    }
    
    //! Gmail
    if ([self.source.identifier isEqualToString:FSSourceGmail]) {
        
        if (self.loadPath) {
            
            GTLRGmailQuery_UsersMessagesGet* mq = [GTLRGmailQuery_UsersMessagesGet queryWithUserId:@"me" identifier:self.loadPath];
            [self.config.gmailService executeQuery:mq
                                 completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket,
                                                     GTLRGmail_Message* message,
                                                     NSError * _Nullable callbackError) {
                                     [self.activityIndicator stopAnimating];
                                     
                                     NSLog(@"%@", message.JSON);
                                     
                                     [self enableUI];
                                     NSArray *items = [FSContentItem itemsFromGTLRGmailMessage:message];
                                     [self.tableViewController contentDataReceived:items isNextPageData:isNextPage];
                                     [self.collectionViewController contentDataReceived:items isNextPageData:isNextPage];
                                     
                                     self.fileListTicket = nil;
                                     
                                     if (completion) {
                                         completion(callbackError == nil);
                                     }
                                     
                                 }];
            
            return;
        }
        
        GTLRGmailQuery_UsersMessagesList *query = [GTLRGmailQuery_UsersMessagesList queryWithUserId:@"me"];
        query.fields = @"nextPageToken,messages";
        
        query.q = [NSString stringWithFormat:@"has:attachment in:inbox"];
        query.maxResults = 20;
        
        if (self.nextPage) {
            query.pageToken = self.nextPage;
        }
        
        dispatch_group_t serviceGroup = dispatch_group_create();
        
        self.fileListTicket = [self.config.gmailService executeQuery:query
                                                   completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                                       GTLRGmail_ListMessagesResponse *fileList,
                                                                       NSError *callbackError) {
                                                       
                                                       if (callbackError.code == 403 || callbackError.code == 401) {
                                                           [self.activityIndicator stopAnimating];
                                                           [self authenticateWithCurrentSource];
                                                           return;
                                                       }
                                                       
                                                       self.nextPage = fileList.nextPageToken;
                                                       
                                                       if (self.nextPage) {
                                                           self.lastPage = NO;
                                                       } else {
                                                           self.lastPage = YES;
                                                       }
                                                       
                                                       NSMutableArray* messages = [fileList.messages mutableCopy];
                                                       
                                                       
                                                       for (GTLRGmail_Message* m in fileList.messages) {
                                                           GTLRGmailQuery_UsersMessagesGet* mq = [GTLRGmailQuery_UsersMessagesGet queryWithUserId:@"me" identifier:m.identifier];
                                                           
                                                           dispatch_group_enter(serviceGroup);
                                                           [self.config.gmailService executeQuery:mq
                                                                                completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket,
                                                                                                    GTLRGmail_Message* message,
                                                                                                    NSError * _Nullable callbackError) {
                                                                                    NSLog(@"%@", message.JSON);
                                                                                    for (GTLRGmail_Message* m in fileList.messages){
                                                                                        if ([m.identifier isEqualToString:message.identifier]) {
                                                                                            [messages replaceObjectAtIndex:[fileList.messages indexOfObject:m] withObject:message];
                                                                                        }
                                                                                    }
                                                                                    
                                                                                    dispatch_group_leave(serviceGroup);
                                                                                }];
                                                       }
                                                       
                                                       
                                                       dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
                                                           // Won't get here until everything has finished
                                                           [self.activityIndicator stopAnimating];
                                                           
                                                           [self enableUI];
                                                           NSArray *items = [FSContentItem itemsFromGTLRGmailMessages:messages];
                                                           [self.tableViewController contentDataReceived:items isNextPageData:isNextPage];
                                                           [self.collectionViewController contentDataReceived:items isNextPageData:isNextPage];
                                                           
                                                           self.fileListTicket = nil;
                                                           
                                                           if (completion) {
                                                               completion(callbackError == nil);
                                                           }
                                                           
                                                       });
                                                       
                                                   }];
        
    }
    
    if ([self.source.identifier isEqualToString:FSSourcePicasa]) {
        
        GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
        query.fields = @"kind,nextPageToken,files";
        
        query.orderBy = @"createdTime desc";
        query.spaces = @"photos";
        
        if (self.nextPage) {
            query.pageToken = self.nextPage;
        }
        
        self.fileListTicket = [self.config.service executeQuery:query
                                              completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                                  GTLRDrive_FileList *fileList,
                                                                  NSError *callbackError) {
                                                  [self.activityIndicator stopAnimating];
                                                  
                                                  if (callbackError.code == 403 || callbackError.code == 400) {
                                                      [self authenticateWithCurrentSource];
                                                      return;
                                                  }
                                                  
                                                  self.nextPage = fileList.nextPageToken;
                                                  
                                                  if (self.nextPage) {
                                                      self.lastPage = NO;
                                                  } else {
                                                      self.lastPage = YES;
                                                  }
                                                  
                                                  [self enableUI];
                                                  NSArray *items = [FSContentItem itemsFromGTLRDriveFileList:fileList];
                                                  [self.tableViewController contentDataReceived:items isNextPageData:isNextPage];
                                                  [self.collectionViewController contentDataReceived:items isNextPageData:isNextPage];
                                                  
                                                  self.fileListTicket = nil;
                                                  
                                                  if (completion) {
                                                      completion(callbackError == nil);
                                                  }
                                                  
                                              }];
        
    }
    
    
}


- (void)loadDirectory:(NSString *)directoryPath {
    FSSourceViewController *directoryController = [[FSSourceViewController alloc] initWithConfig:self.config source:self.source];
    directoryController.loadPath = directoryPath;
    directoryController.inListView = self.inListView;
    [self.navigationController pushViewController:directoryController animated:YES];
}

#pragma mark - Helper methods

- (void)selectContentItem:(FSContentItem *)item atIndexPath:(NSIndexPath *)indexPath forTableView:(BOOL)tableView collectionView:(BOOL)collectionView {
    [self.selectedContent addObject:item];
    
    if (tableView) {
        [self.tableViewController reloadRowAtIndexPath:indexPath];
    }
    
    if (collectionView) {
        [self.collectionViewController reloadCellAtIndexPath:indexPath];
    }
    
    if (self.config.selectMultiple) {
        [self updateToolbar];
    } else {
        [self uploadSelectedContents];
    }
}

- (void)deselectContentItem:(FSContentItem *)item atIndexPath:(NSIndexPath *)indexPath forTableView:(BOOL)tableView collectionView:(BOOL)collectionView {
    [self.selectedContent removeObject:item];
    [self updateToolbar];
    
    if (tableView) {
        [self.tableViewController reloadRowAtIndexPath:indexPath];
    }
    
    if (collectionView) {
        [self.collectionViewController reloadCellAtIndexPath:indexPath];
    }
}

- (void)clearSelectedContent {
    [self.selectedContent removeAllObjects];
    [self updateToolbar];
}

// FSAuthViewControllerDelegate method.
- (void)didAuthenticateWithSource {
    [self.activityIndicator startAnimating];
    [self loadSourceContent:nil isNextPage:NO];
}

- (void)didFailToAuthenticateWithSource {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isContentItemSelected:(FSContentItem *)item {
    return [self.selectedContent containsObject:item];
}

- (void)authenticateWithCurrentSource {
    FSAuthViewController *authController = [[FSAuthViewController alloc] initWithConfig:self.config source:self.source];
    authController.delegate = self;
    
    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive]
        || [self.source.identifier isEqualToString:FSSourceGmail]
        || [self.source.identifier isEqualToString:FSSourcePicasa]) {
        
        [self.navigationController pushViewController:authController animated:NO];
    }else{
        [self.navigationController pushViewController:authController animated:YES];
    }
}


- (void)logout {
    NSString *message = @"Are you sure you want to log out?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logout" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Log out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self performLogout];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)logoutFromGoogleService{
    
    //! Load auth
    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive]) {
        // Remove from Keychain
        [GTMAppAuthFetcherAuthorization
         removeAuthorizationFromKeychainForName:@"kGTMAppAuthExampleAuthorizerKey-Drive"];
        self.config.service.authorizer = nil;
    }
    
    if ([self.source.identifier isEqualToString:FSSourcePicasa]) {
        // Remove from Keychain
        [GTMAppAuthFetcherAuthorization
         removeAuthorizationFromKeychainForName:@"kGTMAppAuthExampleAuthorizerKey-Picasa"];
        self.config.service.authorizer = nil;
    }
    
    if ([self.source.identifier isEqualToString:FSSourceGmail]) {
        // Remove from Keychain
        [GTMAppAuthFetcherAuthorization
         removeAuthorizationFromKeychainForName:@"kGTMAppAuthExampleAuthorizerKey-Gmail"];
        self.config.gmailService.authorizer = nil;

    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)performLogout {
    [self disableUI];
    
    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive]
        || [self.source.identifier isEqualToString:FSSourceGmail]
        || [self.source.identifier isEqualToString:FSSourcePicasa]) {
        [self logoutFromGoogleService];
        return;
    }
    
    FSSession *session = [[FSSession alloc] initWithConfig:self.config];
    NSDictionary *parameters = [session toQueryParametersWithFormat:nil];
    UIAlertController *logoutAlert = [UIAlertController fsAlertLogout];
    [self presentViewController:logoutAlert animated:YES completion:nil];
    
    [Filestack logoutFromSource:self.source.identifier externalDomains:self.source.externalDomains parameters:parameters completionHandler:^(NSError *error) {
        [logoutAlert dismissViewControllerAnimated:YES completion:nil];
        if (error) {
            [self enableUI];
            [self showAlertWithError:error];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)disableUI {
    [self setUIStateEnabled:NO disregardRefreshControl:NO];
}

- (void)enableUI {
    [self setUIStateEnabled:YES disregardRefreshControl:NO];
}

- (void)setUIStateEnabled:(BOOL)enabled disregardRefreshControl:(BOOL)disregardRefreshControl {
    for (UIBarButtonItem *button in self.navigationItem.rightBarButtonItems) {
        button.enabled = enabled;
    }
    
    if (!disregardRefreshControl) {
        [self.tableViewController refreshControlEnabled:enabled];
        [self.collectionViewController refreshControlEnabled:enabled];
    }
}

- (void)enableRefreshControls {
    [self.tableViewController refreshControlEnabled:YES];
    [self.collectionViewController refreshControlEnabled:YES];
}

- (void)listGridSwitch:(UIBarButtonItem *)sender {
    if (self.inListView) {
        self.inListView = NO;
        sender.image = [self imageForViewType];
        [self fsRemoveChildViewController:self.tableViewController];
        [self fsAddChildViewController:self.collectionViewController];
    } else {
        self.inListView = YES;
        sender.image = [self imageForViewType];
        [self fsRemoveChildViewController:self.collectionViewController];
        [self fsAddChildViewController:self.tableViewController];
    }
}

- (void)fsRemoveChildViewController:(UIViewController *)childViewController {
    [childViewController willMoveToParentViewController:nil];
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
}

- (void)fsAddChildViewController:(UIViewController *)childViewController {
    [self addChildViewController:childViewController];
    childViewController.view.frame = self.view.bounds;
    [self.view addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];
}

- (void)showAlertWithError:(NSError *)error {
    UIAlertController *alert = [UIAlertController fsAlertWithError:error];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)triggerDataRefresh:(void (^)(BOOL success))completion {
    self.nextPage = nil;
    [self clearSelectedContent];
    [self setUIStateEnabled:NO disregardRefreshControl:YES];
    [self loadSourceContent:completion isNextPage:NO];
}

- (void)loadNextPage {
    [self setUIStateEnabled:NO disregardRefreshControl:YES];
    [self loadSourceContent:nil isNextPage:YES];
}

@end

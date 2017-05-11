//
//  FSAuthViewController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 11/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSource.h"
#import "FSConfig.h"
#import "FSSettings.h"
#import "FSAuthViewController.h"

#import <Google/SignIn.h>


@interface FSAuthViewController () <UIWebViewDelegate>

@property (nonatomic, strong) FSSource *source;
@property (nonatomic, strong) FSConfig *config;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSArray *allowedUrls;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation FSAuthViewController

static NSString *const fsBaseURL = @"https://www.filestackapi.com";
static NSString *const fsAuthURL = @"%@/api/client/%@/auth/open?m=*/*&key=%@&id=0&modal=false";

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source {
    if ((self = [super init])) {
        _source = source;
        _config = config;
        _allowedUrls = [FSSettings allowedUrlPrefixList];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.source.name;
    
    [self setupActivityIndicator];

    //! Choose auth method
    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive]
        || [self.source.identifier isEqualToString:FSSourceGmail]
        || [self.source.identifier isEqualToString:FSSourcePicasa]) {
        [self authenticateWithGoogleSource];
    }else{
        [self setupWebView];
        [self loadAuthRequest];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
}

- (void)setupWebView {
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
}

- (void)setupActivityIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
}

- (void)loadAuthRequest {
    NSString *urlString = [NSString stringWithFormat:fsAuthURL, fsBaseURL, self.source.service, self.config.apiKey];
    NSURL *requestURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];

    [self.webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)localWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *absoluteString = request.URL.absoluteString;

    if ([request.URL.path isEqualToString:@"/dialog/open"]) {
        [self.navigationController popViewControllerAnimated:YES];

        if ([self.delegate respondsToSelector:@selector(didAuthenticateWithSource)]) {
            [self.delegate didAuthenticateWithSource];
        }

        return NO;
    }

    for (NSString *url in self.allowedUrls) {
        if ([url isEqualToString:@""]) {
            continue;
        }

        if ([absoluteString containsString:url]) {
            return YES;
        }
    }

    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}


#pragma mark - Auth to Google
- (void)authenticateWithGoogleSource {
    GIDSignIn.sharedInstance.uiDelegate = self;
    GIDSignIn.sharedInstance.delegate = self;
    
    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive]) {
        [GIDSignIn sharedInstance].scopes = @[@"https://www.googleapis.com/auth/drive",
                                              @"https://www.googleapis.com/auth/drive.file",
                                              @"https://www.googleapis.com/auth/drive.readonly"];
    }
    
    if ([self.source.identifier isEqualToString:FSSourcePicasa]) {
        [GIDSignIn sharedInstance].scopes = @[@"https://www.googleapis.com/auth/drive.photos.readonly"];
    }
    
    if ([self.source.identifier isEqualToString:FSSourceGmail]) {
        // kGTLRAuthScopeGmailMailGoogleCom
        // kGTLRAuthScopeGmailMetadata
        // kGTLRAuthScopeGmailModify
        // kGTLRAuthScopeGmailReadonly
        [GIDSignIn sharedInstance].scopes = @[@"https://www.googleapis.com/auth/userinfo.email",
                                              @"https://mail.google.com/",
                                              @"https://www.googleapis.com/auth/gmail.modify",
                                              @"https://www.googleapis.com/auth/gmail.readonly"];
    }
    
    [self.activityIndicator startAnimating];
    [GIDSignIn.sharedInstance signIn];
}

#pragma mark _______________________ Delegates _____________________________
// The sign-in flow has finished selecting how to proceed, and the UI should no longer display
// a spinner or other "please wait" element.
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error{
    [self.activityIndicator stopAnimating];
}

// If implemented, this method will be invoked when sign in needs to display a view controller.
// The view controller should be displayed modally (via UIViewController's |presentViewController|
// method, and not pushed unto a navigation controller's stack.
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController{
    [self.navigationController presentViewController:viewController animated:NO completion:nil];
}

// If implemented, this method will be invoked when sign in needs to dismiss a view controller.
// Typically, this should be implemented by calling |dismissViewController| on the passed
// view controller.
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController{
    [self dismissViewControllerAnimated:NO completion:nil];
}


///

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
    if (error == nil && user) {
        self.config.user = user;
        
        if ([self.source.identifier isEqualToString:FSSourceGoogleDrive] ||
            [self.source.identifier isEqualToString:FSSourcePicasa]) {
            
            self.config.service = [[GTLRDriveService alloc] init];
            self.config.service.authorizer = user.authentication.fetcherAuthorizer;
        }
        
        if ([self.source.identifier isEqualToString:FSSourceGmail]) {
            self.config.gmailService = [[GTLRGmailService alloc] init];
            self.config.gmailService.authorizer = user.authentication.fetcherAuthorizer;
        }

    }
    
    // Perform any operations on signed in user here.
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *fullName = user.profile.name;
    NSString *givenName = user.profile.givenName;
    NSString *familyName = user.profile.familyName;
    NSString *email = user.profile.email;
    // ...
    
    if (error == nil) {
        if ([self.delegate respondsToSelector:@selector(didAuthenticateWithSource)]) {
            [self.delegate didAuthenticateWithSource];
        }
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
    self.config.user = nil;
}

@end

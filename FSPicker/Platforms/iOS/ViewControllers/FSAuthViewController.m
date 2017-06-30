//
//  FSAuthViewController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 11/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSource.h"
#import "FSConfig.h"
#import "FSAuthViewController.h"

#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import <QuartzCore/QuartzCore.h>
#import <SafariServices/SafariServices.h>

#import "FSGoogleServicesManager.h"

@interface FSAuthViewController () <UIWebViewDelegate>

@property (nonatomic, strong) FSSource *source;
@property (nonatomic, strong) FSConfig *config;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL didAuthenticate;

@end

@implementation FSAuthViewController

static NSString *const fsBaseURL = @"https://www.filestackapi.com";
static NSString *const fsAuthURL = @"%@/api/client/%@/auth/open?m=*/*&key=%@&id=0&modal=false";

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source {
    if ((self = [super init])) {
        _source = source;
        _config = config;
        _didAuthenticate = NO;
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
    [self notifyDelegateAboutAuthenticationResponse];
}

- (void)notifyDelegateAboutAuthenticationResponse {
    if (self.didAuthenticate) {
        if ([self.delegate respondsToSelector:@selector(didAuthenticateWithSource)]) {
            [self.delegate didAuthenticateWithSource];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(didFailToAuthenticateWithSource)]) {
            [self.delegate didFailToAuthenticateWithSource];
        }
    }
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

    // Detect authentication success response and notify the delegate

    if ([request.URL.path isEqualToString:@"/dialog/open"]) {
        [self.navigationController popViewControllerAnimated:YES];
        self.didAuthenticate = YES;

        return NO;
    }

    // Detect authentication error response and notify the delegate

    NSString *authCallbackOpenPath = [NSString stringWithFormat:@"/api/client/%@/authCallback/open", self.source.identifier];

    if ([request.URL.path hasPrefix:authCallbackOpenPath]) {
        BOOL didError = NO;

        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];

        for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
            if ([queryItem.name isEqualToString:@"error"] ||
                [queryItem.name isEqualToString:@"error_description"]) {

                didError = YES;
                break;
            }
        }

        if (didError) {
            [self.navigationController popViewControllerAnimated:YES];

            return NO;
        }

    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}

/*! @brief Logs a message to stdout and the textfield.
 @param format The format string and arguments.
 */
- (void)logMessage:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
    // gets message as string
    va_list argp;
    va_start(argp, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:argp];
    va_end(argp);

    // outputs to stdout
    NSLog(@"%@", log);

}

- (void)createServiceWith:(GTMAppAuthFetcherAuthorization*)authorization{

    //! Save auth
    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive]) {
        [GTMAppAuthFetcherAuthorization saveAuthorization:authorization
                                        toKeychainForName:@"kGTMAppAuthExampleAuthorizerKey-Drive"];
    }
    if ([self.source.identifier isEqualToString:FSSourcePicasa]) {
        [GTMAppAuthFetcherAuthorization saveAuthorization:authorization
                                        toKeychainForName:@"kGTMAppAuthExampleAuthorizerKey-Picasa"];
    }
    if ([self.source.identifier isEqualToString:FSSourceGmail]) {
        [GTMAppAuthFetcherAuthorization saveAuthorization:authorization
                                        toKeychainForName:@"kGTMAppAuthExampleAuthorizerKey-Gmail"];
    }

    //! Create service
    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive] ||
        [self.source.identifier isEqualToString:FSSourcePicasa]) {

        self.config.service = [[GTLRDriveService alloc] init];
        self.config.service.authorizer = authorization;
    }

    if ([self.source.identifier isEqualToString:FSSourceGmail]) {
        self.config.gmailService = [[GTLRGmailService alloc] init];
        self.config.gmailService.authorizer = authorization;
    }

    if ([self.delegate respondsToSelector:@selector(didAuthenticateWithSource)]) {
        [self.delegate didAuthenticateWithSource];
    }

    [self logMessage:@"Got authorization tokens. Access token: %@",
     authorization.authState.lastTokenResponse.accessToken];

    [self.navigationController popViewControllerAnimated:NO];

}

#pragma mark - Auth to Google
- (void)authenticateWithGoogleSource {
    NSURL *issuer = [NSURL URLWithString:@"https://accounts.google.com"];

    // builds authentication request
    NSArray<NSString *> *scopes = @[];

    if ([self.source.identifier isEqualToString:FSSourceGoogleDrive]) {
        scopes = @[kGTLRAuthScopeDrive];
    }

    if ([self.source.identifier isEqualToString:FSSourcePicasa]) {
        scopes = @[kGTLRAuthScopeDrivePhotosReadonly];
    }

    if ([self.source.identifier isEqualToString:FSSourceGmail]) {
        scopes = @[@"https://www.googleapis.com/auth/userinfo.email",
                   @"https://mail.google.com/",
                   @"https://www.googleapis.com/auth/gmail.modify",
                   @"https://www.googleapis.com/auth/gmail.readonly"];
    }

    // discovers endpoints
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
        if (!configuration) {
            [self logMessage:@"Error retrieving discovery document: %@", [error localizedDescription]];
            [self notifyDelegateAboutAuthenticationResponse];

            return;
        }

        [self logMessage:@"Got configuration: %@", configuration];


        NSString* redirectURI = [FSGoogleServicesManager shared].redirectURI;
        redirectURI = [redirectURI stringByAppendingString:@":/oauthredirect"];

        NSString* clientId = [FSGoogleServicesManager shared].clientId;

        OIDAuthorizationRequest *request =
        [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                      clientId:clientId
                                                        scopes:scopes
                                                   redirectURL:[NSURL URLWithString:redirectURI]
                                                  responseType:OIDResponseTypeCode
                                          additionalParameters:nil];

        // Performs authentication request
        [self logMessage:@"Initiating authorization request with scope: %@", request.scope];

        [FSGoogleServicesManager shared].currentAuthorizationFlow =
        [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                       presentingViewController:self
                                                       callback:^(OIDAuthState *_Nullable authState,
                                                                  NSError *_Nullable error) {
           if (authState) {
               GTMAppAuthFetcherAuthorization *authorization =
               [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];

               if (error == nil) {
                   // Serialize to Keychain
                   [self createServiceWith:authorization];
               }else{
                   [self logMessage:@"Authorization error: %@", [error localizedDescription]];
                   [self notifyDelegateAboutAuthenticationResponse];
               }
           } else {
               [self logMessage:@"Authorization error: %@", [error localizedDescription]];
               [self notifyDelegateAboutAuthenticationResponse];
           }
       }];
    }];
}

@end

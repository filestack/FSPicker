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

@interface FSAuthViewController () <UIWebViewDelegate>

@property (nonatomic, strong) FSSource *source;
@property (nonatomic, strong) FSConfig *config;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation FSAuthViewController

static NSString *const fsBaseURL = @"https://www.filestackapi.com";
static NSString *const fsAuthURL = @"%@/api/client/%@/auth/open?m=*/*&key=%@&id=0&modal=false";

- (instancetype)initWithConfig:(FSConfig *)config source:(FSSource *)source {
    if ((self = [super init])) {
        _source = source;
        _config = config;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.source.name;
    [self setupWebView];
    [self setupActivityIndicator];
    [self loadAuthRequest];
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

    // Detect authentication success response and notify the delegate

    if ([request.URL.path isEqualToString:@"/dialog/open"]) {
        [self.navigationController popViewControllerAnimated:YES];

        if ([self.delegate respondsToSelector:@selector(didAuthenticateWithSource)]) {
            [self.delegate didAuthenticateWithSource];
        }

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

            if ([self.delegate respondsToSelector:@selector(didFailToAuthenticateWithSource)]) {
                [self.delegate didFailToAuthenticateWithSource];
            }

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

@end

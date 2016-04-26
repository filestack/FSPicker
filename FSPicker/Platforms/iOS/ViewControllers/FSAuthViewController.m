//
//  FSAuthViewController.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 11/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSAuthViewController.h"
#import "FSProgressView.h"
#import "UINavigationController+Progress.h"
#import "FSSource.h"
#import "FSConfig.h"
#import "FSSettings.h"
@import WebKit;

@interface FSAuthViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) FSSource *source;
@property (nonatomic, strong) FSConfig *config;
@property (nonatomic, strong) NSArray *allowedUrls;

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
    [self setupWebView];
    [self loadAuthRequest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    [self.navigationController fsResetProgressView];
}

- (void)setupWebView {
    // Workaround for WKWebView memory leak;
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.selectionGranularity = WKSelectionGranularityCharacter;
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)loadAuthRequest {
    NSString *urlString = [NSString stringWithFormat:fsAuthURL, fsBaseURL, self.source.service, self.config.apiKey];
    NSURL *requestURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];

    [self.webView loadRequest:request];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.navigationController.fsProgressView animateFadeOutAndHide];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURLRequest *request = navigationAction.request;
    NSString *absoluteString = request.URL.absoluteString;

    NSLog(@"request.URL.path: %@", request.URL.path);
    NSLog(@"absoluteString: %@", absoluteString);

    if ([request.URL.path isEqualToString:@"/dialog/open"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        [self.navigationController popViewControllerAnimated:YES];
        if ([self.delegate respondsToSelector:@selector(didAuthenticateWithSource)]) {
            [self.delegate didAuthenticateWithSource];
        }
        return;
    }

    for (NSString *url in self.allowedUrls) {
        if ([absoluteString containsString:url]) {
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
    }

    decisionHandler(WKNavigationActionPolicyCancel);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self.navigationController.fsProgressView setProgress:(float)self.webView.estimatedProgress animated:YES];
        if ((int)self.webView.estimatedProgress == 1) {
            [self.navigationController.fsProgressView animateFadeOutAndHide];
        }
    }
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
